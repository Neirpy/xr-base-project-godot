# Godot XR Base Project 🥽

Welcome to the **Godot XR Base Project**! This project was designed as a solid, ready-to-use foundation for professionals and developers looking to learn and create Virtual Reality (XR) experiences using the **Godot** engine.

The goal of this project is to provide a pre-configured environment to save you time and let you focus entirely on creation. This README is structured step-by-step so you can easily understand the project architecture.

> 🇫🇷 **Version Française :** [Cliquez ici pour lire le README en Français](README.md)

---

## 📋 Table of Contents

- [Godot XR Base Project 🥽](#godot-xr-base-project-)
  - [📋 Table of Contents](#-table-of-contents)
  - [1. Prerequisites and Basics](#1-prerequisites-and-basics)
  - [2. Installing Addons](#2-installing-addons)
  - [3. Project Configuration](#3-project-configuration)
  - [4. Creating the Environment](#4-creating-the-environment)
  - [5. XR Character and Hand Tracking Setup](#5-xr-character-and-hand-tracking-setup)
    - [A. Base Structure](#a-base-structure)
    - [B. Tracked Hands Setup](#b-tracked-hands-setup)
    - [C. Physical Controllers (XRController3D)](#c-physical-controllers-xrcontroller3d)
  - [6. Available Interactive Elements](#6-available-interactive-elements)
  - [7. Export Configuration (Meta Quest / Android)](#7-export-configuration-meta-quest--android)
    - [A. Development Environment Setup](#a-development-environment-setup)
    - [B. Configuration in Godot](#b-configuration-in-godot)
  - [8. Additional Resources](#8-additional-resources)

---

## 1. Prerequisites and Basics

Before diving into the project, it is essential to understand the fundamental concepts of XR in Godot:

* **Godot Basics:** How scenes, nodes, and scripts work.
* **Hand Tracking:** Tracking the user's hands without physical controllers.
* **Passthrough:** Displaying the user's real-world environment (Mixed Reality).
* **Interactions:** Grabbing, pointing, and interacting with virtual objects.

If you are not comfortable with these concepts, we strongly encourage you to check out the recommendations below.

> **💡 Tutorial Recommendations:** To deepen your knowledge, we highly recommend tutorials from:
> * **Malcolm Nixon** (Godot XR with hand tracking, creating custom gestures)
> * **Bastiaan Olij** (Godot XR Tools features, managing the physics of the player character)
> * **Brackeys** (For Godot basics: 2D, 3D, and Shaders)

---

## 2. Installing Addons

This project relies on several essential plugins for XR. Make sure they are installed and enabled via the Asset Library or present in your `addons/` folder:

* **Godot XR Tools:** The main toolkit for locomotion and interactions.
* **OpenXR Vendors:** Specific support for various hardware vendors (Meta, Pico, etc.).
* **HandPose Detector:** Hand pose detection system (thumbs up, fist, pinch, etc.).

---

## 3. Project Configuration

For optimal rendering on standalone headsets, the following project settings must be verified (in `Project > Project Settings`):

* **Textures (VRAM Compression):**
  * Enable `S3TC`
  * Enable `ETC2` (Essential for Android/Quest)
* **Plugins:** 
  * Ensure `Godot XR Tools` is enabled in the `Plugins` tab.
* **XR / OpenXR:**
  * Check `Enabled`.
  * `Reference`: Set to `Local Floor` (The room's floor is point 0).
  * `Foveation Level`: Set to `High`.
  * Check `Foveation dynamic`.
  * `Color Space`: `REC709`.
  * **Shaders:** Do not forget to enable the necessary XR shaders.

---

## 4. Creating the Environment

The base scene of your XR experience must contain the following elements:

1. A **StartXR** node (often via a script attached to the root or a specific Godot XR Tools node) to initialize OpenXR at launch.
2. A **WorldEnvironment** to handle global lighting and the sky.
3. A **Floor** with collision (StaticBody3D + CollisionShape3D + MeshInstance3D) to prevent falling infinitely.
4. A **DirectionalLight3D** to illuminate the scene.
5. A **CharacterXR** or a **CharacterWH** (depending on your control style), which acts as the virtual representation of your player.

> * **CharacterXR**: This is the character with hand tracking that will physically move in our virtual world. It is used in **main_xr.tscn**.
> * **CharacterWH**: This is the character "Without Handtracking" (no hand tracking) that uses joysticks to move and turn the camera. It is used in **main_vr.tscn**.

---

## 5. XR Character and Hand Tracking Setup

Here is the structure for the player's avatar (`CharacterBody`) and the hand tracking setup:

### A. Base Structure
* **CharacterBody3D** (with a script pointing to its logic)
  * **XROrigin3D** (The player's center point in VR, with its script)
    * **XRCamera3D** (The player's head/eyes. Attach a script for the *Fade* system for transitions if needed).

### B. Tracked Hands Setup
Create an **XRNode3D** node and rename it, for example, `LeftTrackedHand`.

1. **3D Model:** Add a 3D hand model as a child.
2. **Skeleton:** Expand the model's children until you find the `Skeleton3D`.
   * Add an **XRHandModifier3D** as a child of `Skeleton3D`.
   * Add a **BoneAttachment3D**: In the inspector, select the `index` finger and attach the *poke* system (button pressing interaction) found in the file search browser.
3. **Pose Detection:**
   * Add a **HandPoseDetector**.
   * Create a `HandPoseSet` (an array of HandPoses).
   * Configure the desired poses: `index pinch` and `fist`.
4. **Controller (HandPoseController):**
   * Add a **HandPoseController** child.
   * Change the *Tracker Name* to point to the desired hand: `/user/hand_pose_controller/left`.
   * Setup the *pose types*.
   * **Action Map:** Create the elements and add `fist` and `index_pinch` with the `grip` parameter set to `Float`.

### C. Physical Controllers (XRController3D)
*If you use physical controllers in addition to or instead of hand tracking:*
* Use an **XRController3D** node (depending on whether you want hand tracking or not).
* Link it by assigning: `/user/hand_pose_controller/left` (or `right`).
* Add the **FunctionPickup** function (found in Godot XR Tools resources) as a child of this controller to allow grabbing objects.

*Note: For a character without Hand Tracking, the principle remains the same, but you can leave the pose settings on their default values.*

---

## 6. Available Interactive Elements

This project includes pre-configured elements in the scene that you can use and study:

* **Interactive button:** Buttons that can be physically pressed. Their mechanics are simple: they have a detection area. When you put your finger in it, the button triggers a "pressed" animation, and inversely when you pull away. You can make new ones by creating an inherited scene from `/assets/base_objects/interactive_button.tscn`.
* **Viewport 2D and 3D:** Floating UI interfaces in VR space. Slightly more complex to set up than a 3D button, this element allows you to create 2D interfaces embedded in your 3D world. To achieve this, you need to create a **CanvasLayer** scene and assign it to `Content -> Scene` of your **Viewport_2D_3D**. You can create new ones by creating an inherited scene from `/assets/base_objects/flat_button.tscn`. 
* **Grab Element:** Objects that can be grabbed and manipulated. You need to insert your 3D model into it, and then in the **CollisionShape3D**, select a shape that matches your object. The final step is to put only the mesh of your 3D object into **XRToolsHighlightVisible** and change its surface overrides by adding the provided **grab_object** material as an example. You can make new ones by creating an inherited scene from `/assets/base_objects/pickable_base.tscn`.
* **Snap Zone:** Magnetic zones to snap or store objects (e.g., spatial inventory). You can add some nuance by creating groups on your **grab_objects** and specifying in **Grab Require** the items your Snap Zone is allowed to catch. You can make new ones by creating an inherited scene from `/assets/base_objects/snap_zone_base.tscn`.

---

## 7. Export Configuration (Meta Quest / Android)

To test and export your project directly on a standalone headset (like the Meta Quest), here is the complete procedure:

### A. Development Environment Setup
1. Install **Android Studio** (Not mandatory, but it makes things easier).
2. From Android Studio, install the correct versions (via SDK Manager):
   * **Android SDK Platform-Tools:** version 35.0.0 (or later).
   * **Android SDK Build-Tools:** version 35.0.0.
   * **Android SDK Platform:** 35.
   * **Android SDK Command-line Tools:** (latest).
3. Ensure that **NDK and CMake** are installed and configured:
   * CMake: version `3.10.2.4988404`.
   * NDK: version `r28b (28.1.13356709)`.
4. Install **Open-JDK 17**: [Adoptium Download Link](https://adoptium.net/en-GB/temurin/releases/?variant=openjdk17&version=17)

### B. Configuration in Godot
1. Back in Godot: Go to **Editor > Editor Settings > Export > Android** and change the paths to the SDK and JDK.
2. Go to **Project > Install Android Build Template**.
3. Go to **Project > Export**:
   * Create a new **Meta** profile.
   * Check **Use Gradle Build**.
   * Change the application's **Unique Name**.
   * Fill in the **Name** field.
   * **XR Mode:** `OpenXR`.
   * **Enable Meta Plugin:** Checked (if exporting to Quest).
   * Check the **Meta XR Features** (select required permissions).
4. **Run on Android:** Plug in your headset or export the APK to install it manually.

> If you encounter any errors, please check the Godot documentation: https://docs.godotengine.org/en/stable/tutorials/xr/index.html

---

## 8. Additional Resources

Here is a selection of recommended tutorials and documentation to learn Godot XR (especially with hand tracking) and to take things further:

* **[Video 1 - AR and Hand Tracking Setup](https://www.youtube.com/watch?v=HeFut3Htrcw)**: Tutorial by Malcolm Nixon showing how to import hands and set up the environment for AR (passthrough). He also covers the `pickup` function, which is frequently used later.
* **[Video 2 - Hand Interactions, PlayerBody, and Teleportation](https://www.youtube.com/watch?v=HeFut3Htrcw&t=403s)** *(Resume at 6:43 of the previous video)*: Malcolm re-explains how to handle hand interactions and introduces the concept of teleportation and the *PlayerBody* (very useful if you want a physical body for the player in the scene, though it can sometimes cause physics issues). He also demonstrates customization options for pickable objects and how to code a "fireball."
* **[Video 3 - Custom Hand Poses](https://www.youtube.com/watch?v=xB1TJXy77fI&t=1s)** *(Optional)*: Learn how to create custom hand poses to design your own interactions. The software shown in Godot is very useful for testing and configuring interactions beforehand.
* **[Video 4 - Godot XR Tools in Depth](https://www.youtube.com/watch?v=HwN3g9Mq0f8)** *(Optional)*: Bastiaan Olij explains how the Godot XR Tools plugin works, giving you a good understanding of its overall potential (even though we've already covered the main features).
* **[Video 5 - Pickable Objects and Customization](https://www.youtube.com/watch?v=u66RwHdpeuQ)**: A deeper dive into grabable objects with customization tips. Note that some tricks (like *grab points*) do not work in pure *hand tracking* without physical controllers.
* **[Video 6 - Snap Zones (Important)](https://www.youtube.com/watch?v=UUwpEY_S9os)**: This tutorial focuses on **Snap Zones**: how to make an object snap to a specific place and stay there. It also shows how to import a GLTF model, customize the pickup for it, and dynamically enable/disable Snap Zones.
* **[Video 7 - Exporting to Meta Quest](https://www.youtube.com/watch?v=LZ9UKR48b0Y)**: Full explanations on how to set up and install the prerequisites to export a project to a Meta Quest headset.

### Official Documentation (Very Important)

Carefully follow these pages from the official documentation, as they cover all the critical setup steps:
* **[Exporting for Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)**
* **[Compiling for Android](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_for_android.html#doc-compiling-for-android)**

### XR Plugins

* **[Godot OpenXR Vendors - Documentation](https://godotvr.github.io/godot_openxr_vendors/)**
* **[Godot XR Tools - Documentation](https://godotvr.github.io/godot-xr-tools/docs/home/)**

Once everything is set up, all that's left is for you to experiment and design interesting interactive experiences!
