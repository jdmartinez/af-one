# AFOne — AI Product Brief

## Product Vision

AFOne is an iOS application that helps patients with **paroxysmal atrial fibrillation (PAF)** understand and monitor their heart rhythm using data collected by Apple Watch and stored in Apple Health. The application transforms raw physiological measurements into **clear clinical insights** that help patients understand their condition and communicate effectively with their cardiologist. The product focuses on **interpretation and understanding**, not raw data collection.

AFOne is **not a medical device** and does not diagnose or treat disease.

## Problem

Wearable devices generate large volumes of heart-related data, but most health applications only display isolated measurements without interpretation.

Patients with atrial fibrillation often cannot easily answer important questions such as:

* How often am I experiencing AF episodes?
* How much time am I spending in AF overall?
* Are my symptoms actually caused by arrhythmia?
* Are there patterns or triggers behind my episodes?
* Are my medications helping?

This lack of interpretation limits the usefulness of wearable health data in real-life disease management.

AFOne solves this by converting rhythm data into **structured insights, patterns, and summaries that are meaningful for both patients and physicians**.

## Target User

A patient diagnosed with **paroxysmal atrial fibrillation** who regularly wears an Apple Watch capable of detecting irregular heart rhythms.

Typical user goals:

* Understand their current rhythm status
* Monitor AF burden over time
* Track symptoms and their relationship with rhythm
* Identify lifestyle triggers
* Evaluate medication effectiveness
* Share structured information with their cardiologist
* Provide key medical information quickly during emergencies

The product should prioritize **clarity, simplicity, and clinical usefulness**.

## Core Product Principles

The application should follow these guiding principles:

* **Interpretation over raw data**. Prioritize insights, summaries, and trends instead of raw physiological measurements.
* **Clinically meaningful information**. Outputs should be understandable to both patients and cardiologists.
* **Private by design**. Health data must remain under the user's control and should not be shared automatically.
* **Patient empowerment**. The app should help users understand their condition and recognize patterns over time.
* **Physician collaboration**. Information produced by the app should support medical consultations.
* **Safety and transparency**. The product must clearly communicate that it is **not a medical device** and does not replace professional medical advice.

## Core Capabilities

### Dashboard

The dashboard is the primary screen of the application. Its purpose is to give users an immediate understanding of their current status.

The dashboard should prioritize:

* Current rhythm context
* Recent AF activity
* Key summary metrics
* Quick access to important actions

Users should be able to understand their situation within a few seconds of opening the app.

### Rhythm Monitoring Overview

The application provides a clear overview of the user's recent heart rhythm activity.

Users should be able to quickly understand:

* Whether AF episodes have occurred recently
* How frequently they occur
* Whether the situation is improving or worsening

The overview should prioritize **clarity and rapid comprehension**.

### AF Burden

The application must calculate and present **AF burden**, defined as the proportion of monitored time spent in atrial fibrillation.

Users should be able to observe this metric across multiple time windows such as:

* Recent daily activity
* Weekly patterns
* Longer-term trends

AF burden is one of the most important indicators for evaluating atrial fibrillation progression.

### Rhythm Timeline

Users should be able to visualize rhythm status across time.

The timeline should indicate when rhythm was:

* Normal
* Atrial fibrillation
* Unknown or not recorded

The purpose is to reveal patterns such as:

* Nocturnal episodes
* Clusters of episodes
* Activity-related episodes

### Episode History

All detected atrial fibrillation episodes should be recorded and accessible.

Users should be able to review the history of episodes including:

* When the episode occurred
* How long it lasted
* Heart rate behavior during the episode
* Any associated symptoms

This creates a clear historical record of arrhythmia events.

### Heart Rate Behaviour During AF

The application should help users understand how their heart rate behaves during AF episodes.

This includes summarizing how fast the heart typically beats during AF and highlighting unusually high rates.

This information supports evaluation of **rate control effectiveness**.

### Symptom Logging

Users must be able to quickly record symptoms when they feel something unusual.

Examples may include:

* Palpitations
* Anxiety or nervousness
* Dizziness
* Fatigue
* Shortness of breath
* Chest discomfort
* Unspecified abnormal sensation

Each symptom record must be associated with the moment it occurred.

### Symptom–Rhythm Correlation

Over time the app should help users understand whether their symptoms correspond to actual rhythm disturbances.

The system should analyze historical data and indicate patterns such as:

* Symptoms that coincide with AF
* Symptoms occurring without arrhythmia
* Possible irregular beats not classified as AF

This helps distinguish **arrhythmia-related symptoms from benign sensations**.

### Medication Awareness

The application should allow users to see medications recorded in their health records and understand their relationship to rhythm activity. The goal is to help identify patterns such as:

* Episodes occurring near medication timing
* Consistency of medication intake

This information is intended to support physician discussions rather than replace medical guidance.

### Trigger Tracking

Users should be able to log lifestyle factors that might precede episodes.

Examples include:

* Alcohol
* Caffeine
* Stress
* Poor sleep
* Heavy meals
* Intense exercise

The system should accumulate this information and help users identify **possible personal trigger patterns**.

### Long‑Term Trends

The product should allow users to observe how their condition evolves over time. Important metrics such as AF burden, episode frequency, and rhythm patterns should be observable across longer time horizons. This supports both patient understanding and physician evaluation.

### Clinical Reports

The application should be able to generate structured summaries that patients can share with their cardiologist.

Reports should help physicians quickly understand:

* AF burden over a defined period
* Episode history
* Trends and changes
* Symptom relationships
* Medication context

The objective is to make cardiology consultations **more efficient and data‑informed**.

### Emergency Information

The application should provide quick access to essential information in case the user needs urgent care.

This information should include:

* Diagnosis
* Current medications
* Recent rhythm activity

The goal is to help healthcare professionals rapidly understand the patient's situation.

### Notifications

The application should notify users about relevant rhythm-related events such as:

* Detection of an atrial fibrillation episode
* Episodes lasting unusually long
* Significant increases in AF burden

Notifications should be informative without generating unnecessary anxiety.

## Optional Intelligent Insights

Some features may use on-device intelligence to provide deeper insights, such as:

* Early recognition of possible episode onset
* Detection of unusual changes in baseline metrics
* Estimation of short-term episode risk
* Automatic generation of report summaries

These capabilities are **enhancements** and should not be required for the core product to function.

## Privacy Expectations

Health data is highly sensitive. The product must respect the following expectations:

* The user retains full control over their health information
* Data should never be shared automatically
* Users must clearly understand how their data is used

Trust and privacy are fundamental to the product.

## Safety and Medical Disclaimer

AFOne is **not a medical device**. The application provides informational insights designed to help patients understand their heart rhythm and communicate with healthcare professionals. Users must clearly understand that:

* The app does not provide medical diagnosis
* The app does not replace professional medical advice
* Serious symptoms require immediate medical attention

This message should remain clearly visible throughout the user experience.

## Desired Outcome

If the product succeeds, users should be able to:

* Understand their atrial fibrillation patterns
* Recognize possible triggers
* Track the effectiveness of treatments
* Provide structured information to their cardiologist
* Feel more informed and confident about their condition

AFOne ultimately transforms **passive wearable data into meaningful cardiac insight**.

## Non-Goals

To avoid ambiguity, the following capabilities are **explicitly out of scope** for the product:

* The application does **not diagnose medical conditions**.
* The application does **not replace medical advice or physician evaluation**.
* The application does **not modify or write health data into Apple Health records (except user-entered notes such as symptoms or triggers if supported by the platform)**.
* The application does **not provide treatment recommendations or medication guidance.
* The application does **not require cloud infrastructure or backend services**.
* The application does **not function as a real-time cardiac monitor or emergency detection system**.

The goal of AFOne is **interpretation and communication**, not medical decision-making.

## Quality Bar

The application should meet the following quality expectations:

* **Clarity**. Information should be understandable within seconds. The user should immediately grasp their rhythm status and recent activity.
* **Clinical Credibility**. Metrics and terminology should be consistent with how cardiologists interpret atrial fibrillation monitoring data.
* **Simplicity**. The interface should avoid unnecessary complexity and prioritize the most important information.
* **Reliability**. Data shown to the user should reflect the underlying health records accurately and consistently.
* **Performance**. The application should feel fast and responsive. Views that summarize historical data should load quickly and remain smooth to navigate.

## Privacy

Health data **MUST** remain on the device and under the user's control.

## Constraints

The implementation must respect the following product constraints:

* The application targets **modern iOS devices**.
* Apple Watch is expected as the primary source of rhythm information.
* The application relies on **health data recorded by the Apple ecosystem**.
* Data originates from Apple Watch measurements and Apple Health records.
* The user always retains control of their health information.
* Data sharing must always be initiated explicitly by the user.
* The application should remain functional without requiring network connectivity for its core capabilities.
* Reports generated by the application should be understandable by healthcare professionals even if they are unfamiliar with the app.

## Definition of Success

The product succeeds if users can:

* Understand their atrial fibrillation patterns without interpreting raw sensor data
* Recognize meaningful changes in their condition over time
* Bring clear and structured information to cardiology appointments
* Feel more informed and less uncertain about their rhythm activity

Success means transforming **complex wearable data into clear personal cardiac insight**.
