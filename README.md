# Godot XR Base Project 🥽

Bienvenue dans le **Godot XR Base Project** ! Ce projet a été conçu comme une base solide et prête à l'emploi pour les professionnels et les développeurs souhaitant apprendre et créer des expériences en Réalité Virtuelle (XR) sur le moteur **Godot**. 

L'objectif de ce projet est de vous fournir un environnement préconfiguré pour vous faire gagner du temps et vous permettre de vous concentrer directement sur la création. Ce README est structuré de manière à pouvoir comprendre l'architecture du projet pas à pas.

> 🌐 **English Version:** [Click here for the English README](README_EN.md)

---

## 📋 Sommaire

1. [Prérequis et Notions de Base](#1-prérequis-et-notions-de-base)
2. [Installation des Addons](#2-installation-des-addons)
3. [Configuration du Projet](#3-configuration-du-projet)
4. [Création de l'Environnement](#4-création-de-lenvironnement)
5. [Configuration du Personnage XR et Hand Tracking](#5-configuration-du-personnage-xr-et-hand-tracking)
6. [Éléments Interactifs Disponibles](#6-éléments-interactifs-disponibles)
7. [Configuration de l'Export (Meta Quest / Android)](#7-configuration-de-lexport-meta-quest--android)

---

## 1. Prérequis et Notions de Base

Avant de plonger dans le projet, il est essentiel de comprendre les concepts fondamentaux de la XR sous Godot :

* **Base de Godot :** Fonctionnement des scènes, des nœuds et des scripts.
* **Hand Tracking :** Suivi des mains de l'utilisateur sans contrôleurs physiques.
* **Passthrough :** Affichage de l'environnement réel de l'utilisateur (Réalité Mixte).
* **Interactions :** Saisir, pointer, et interagir avec des objets virtuels.

> **💡 Recommandations de Tutoriels :** Pour approfondir vos connaissances, nous vous recommandons fortement les tutoriels de :
> * **Malcolm Nixon** (Créateur de Godot XR Tools)
> * **Bastiaan Olij** (Mainteneur principal de l'architecture XR de Godot)
> * **Brackeys** (Pour les bases de Godot)

---

## 2. Installation des Addons

Ce projet repose sur plusieurs plugins essentiels pour la XR. Assurez-vous qu'ils sont bien installés et activés via l'Asset Library ou présents dans votre dossier `addons/` :

* **Godot XR Tools :** Boîte à outils principale pour le déplacement et les interactions.
* **OpenXR Vendors :** Support spécifique pour différents constructeurs (Meta, Pico, etc.).
* **HandPose Detector :** Système de détection de poses des mains (pouce levé, poing, pincement, etc.).

---

## 3. Configuration du Projet

Pour un rendu optimal sur casque autonome, les paramètres de projet suivants doivent être vérifiés (dans `Projet > Paramètres du projet`) :

* **Textures (VRAM Compression) :**
  * Activer `S3TC`
  * Activer `ETC2` (Indispensable pour Android/Quest)
* **Plugins :** 
  * Vérifier que `Godot XR Tools` est activé dans l'onglet `Plugins`.
* **XR / OpenXR :**
  * Cochez `Enabled` (Activé).
  * `Reference` : Définir sur `Local Floor` (Le sol de la pièce est le point 0).
  * `Foveation Level` : Régler sur `High`.
  * Cochez `Foveation dynamic`.
  * `Color Space` : `REC709`.
  * **Shaders :** N'oubliez pas d'activer les shaders XR nécessaires.

---

## 4. Création de l'Environnement

La scène de base de votre expérience XR doit contenir les éléments suivants :

1. Un nœud **StartXR** (souvent via un script attaché à la racine ou un nœud spécifique de Godot XR Tools) pour initialiser l'OpenXR au lancement.
2. Un **WorldEnvironment** pour gérer l'éclairage global et le ciel.
3. Un **Sol** avec collision (StaticBody3D + CollisionShape3D + MeshInstance3D) pour ne pas tomber à l'infini.
4. Une **DirectionalLight3D** pour éclairer la scène.

---

## 5. Configuration du Personnage XR et Hand Tracking

Voici la structure de l'avatar du joueur (`CharacterBody`) et la mise en place du suivi des mains :

### A. Structure de Base
* **CharacterBody3D** (avec un script pointant sur sa logique)
  * **XROrigin3D** (Point central du joueur en VR, avec son script)
    * **XRCamera3D** (La tête / les yeux du joueur. Y attacher un script pour le système de *Fade* pour les transitions si besoin).

### B. Configuration des Mains (Tracked Hands)
Créer un nœud **XRNode3D** et le renommer, par exemple, `LeftTrackedHand`.

1. **Modèle 3D :** Ajouter le modèle 3D d'une main en enfant.
2. **Squelette :** Développer les enfants du modèle jusqu'à trouver le `Skeleton3D`.
   * Ajouter un **XRHandModifier3D** en enfant du `Skeleton3D`.
   * Ajouter un **BoneAttachment3D** : Dans l'inspecteur, sélectionner le doigt `index` et attacher le système de *poke* (interaction de type pression avec le doigt) trouvé dans le navigateur de recherche.
3. **Détection de Poses :**
   * Ajouter un **HandPoseDetector**.
   * Créer un `HandPoseSet` (un Array de HandPoses).
   * Y configurer les poses désirées : `index pinch` (pincement) et `fist` (poing fermé).
4. **Contrôleur (HandPoseController) :**
   * Ajouter un enfant **HandPoseController**.
   * Changer le nom du tracker (*Tracker Name*) pour pointer sur la main voulue : `/user/hand_pose_controller/left`.
   * Expliquer les types de poses (*pose type*).
   * **Action Map :** Créer les éléments et ajouter `fist` et `index_pinch` avec le paramètre `grip` en mode `Float`.

### C. Contrôleurs Physiques (XRController3D)
*Si vous utilisez des manettes (contrôleurs physiques classiques) ou que vous intégrez le Hand Tracking :*
* Utiliser un nœud **XRController3D** (qui dépend de si on veut faire du hand tracking ou non).
* Le lier en assignant : `/user/hand_pose_controller/left` (ou `right`).
* Mettre la fonction **FunctionPickup** (trouvable dans les ressources Godot XR Tools) en tant qu'enfant de ce contrôleur pour permettre de saisir des objets.

*Note : Pour un personnage sans Hand Tracking, le principe reste le même mais vous pouvez laisser les paramètres de pause par défaut.*

---

## 6. Éléments Interactifs Disponibles

Ce projet inclut des éléments préconfigurés dans la scène que vous pouvez utiliser et étudier :

* **Interactive button :** Boutons pressables et interactifs.
* **Viewport 2D et 3D :** Interfaces UI flottantes dans l'espace VR.
* **Grab Element :** Objets saisissables et manipulables.
* **Snap Zone :** Zones d'aimantation pour venir accrocher ou déposer des objets (ex: inventaire spatial).

---

## 7. Configuration de l'Export (Meta Quest / Android)

Pour tester et exporter votre projet sur un casque autonome (comme le Meta Quest), voici la procédure complète :

### A. Préparation de l'environnement de développement
1. Installer **Android Studio**.
2. Depuis Android Studio, installer les bonnes versions (via le SDK Manager) :
   * **Android SDK Platform-Tools :** version 35.0.0 (ou supérieure).
   * **Android SDK Build-Tools :** version 35.0.0.
   * **Android SDK Platform :** 35.
   * **Android SDK Command-line Tools :** (Dernière version / latest).
3. Assurez-vous que **NDK et CMake** sont installés et configurés :
   * CMake : version `3.10.2.4988404`.
   * NDK : version `r28b (28.1.13356709)`.
4. Installer **Open-JDK 17** : [Lien de téléchargement Adoptium](https://adoptium.net/fr/temurin/releases?variant=openjdk17&version=17&os=any&arch=any)

### B. Configuration dans Godot
1. Retour dans Godot : Aller dans **Editor > Editor Settings > Export > Android** et changer les chemins vers les SDK et JDK.
2. Aller dans **Project > Install Android Build Template**.
3. Aller dans **Project > Export** :
   * Créer un nouveau profil **Meta**.
   * Cochez **Use Gradle Build**.
   * Changer le nom unique (**Unique Name**) de l'application.
   * Remplir le champ **Name**.
   * **XR Mode :** `OpenXR`.
   * **Enable Meta Plugin :** Coché (si export vers Quest).
   * Regarder les **Meta XR Features** (sélectionner les permissions nécessaires).
4. **Lancer son export** : Branchez votre casque ou exportez l'APK pour l'installer manuellement.
