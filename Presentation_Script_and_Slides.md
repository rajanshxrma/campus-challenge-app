# Campus Challenge — Seamless 2-Part Presentation Script

**Course:** CSC 4360/6360 — Mobile App Development
**Team:** U30 (Rajan Sharma, Michael Irving)
**Goal Time:** 15–20 minutes total

> **The Recording Plan (Just 1 Edit!)**
> You (Rajan) will record "Video 1". You will share your screen, show Slides 1 through 4, explain the app, and answer your assigned Q&A questions on Slide 5. 
> Then, you stop recording.
> 
> Michael will record "Video 2". He will share his screen on Slide 5, answer his assigned Q&A questions, and finish with the final feature trace (Question 12).
> 
> You simply drag and drop Video 1 and Video 2 back-to-back in an editor. One cut, highly seamless, incredibly easy. No jumping back and forth!

---

## 🎙️ VIDEO 1 SCRIPT: RAJAN SHARMA
**[WHAT YOU SHARE ON SCREEN: The PowerPoint Slides in presentation mode]**

**(Slide 1: Title Screen)**  
**Rajan:** "Hello everyone, we are Team U30. My name is Rajan Sharma, and my role for this project focused on Database Models, Provider State, and CRUD Logic. My partner is Michael Irving, who focused on Widget Composition, UI/UX flows, and Data Visualization. Today, we are very excited to present our Flutter application, 'Campus Challenge' — an app designed to help students build better habits."

*(Rajan switches to Slide 2)*

**(Slide 2: The Problem & Solution)**  
**Rajan:** "The core problem we wanted to solve is that college students struggle to build and maintain consistent daily habits amid busy schedules. It’s easy to say you’ll study or exercise, but hard to actually track it. 

Our solution is a streamlined, mobile habit tracker. It allows students to set daily goals, tracks their progress with streak counters, and gives them interactive data visualization so they can actually see their consistency over time, keeping them motivated."

*(Rajan switches to Slide 3)*

**(Slide 3: App Demo & Features)**  
**Rajan:** "Here is a look at the actual application. On the left, you can see our main Dashboard. This acts as the central hub where users can view their active challenges, see their 'day streaks' represented by the fire icons, and check off their daily goals. The circle at the top visually fills up as you complete tasks throughout the day.

In the middle screenshot, you can see our Challenge Details screen. This is one of our bonus features. We utilized the `fl_chart` package to generate dynamic, weekly bar charts so users can visualize exactly which days of the week they were most productive. 

On the right is our Progress tab. As you can see, the app also fully supports system-wide Dark Mode—another bonus feature we implemented using `SharedPreferences` to save the user's theme state locally."

*(Rajan switches to Slide 4)*

**(Slide 4: Architecture & Persistence)**  
**Rajan:** "Under the hood, we built this app with a clean separation of concerns. For state management, we use the `Provider` pattern, which allows us to instantly update the UI globally—like when a user toggles Dark Mode. 

For data persistence, we actually use two methods. For lightweight user settings, we use `SharedPreferences`. But for the heavy lifting—storing the dynamic challenges and logging every single completion event—we implemented a full relational `SQLite` database. We have a `challenges` table and a `completions` table that are linked via foreign keys, allowing us to accurately query streaks and weekly data."

*(Rajan switches to Slide 5)*

**(Slide 5: Q&A Session)**  
**Rajan:** "Now, we will transition into the technical Q&A session. I'll be answering the first half of our selected questions, covering the database and architecture, and then Michael will take over to discuss the UI, workflow, and a feature trace."

**(Q1) What are the key advantages of using Flutter for this cross-platform project?**  
**Rajan:** "Flutter allowed us to write our UI and business logic once and deploy it anywhere. The hot-reload feature was crucial for rapidly iterating on our design—especially for dialing in our bonus features like the dark mode theme and the fl_chart progress graphs."

**(Q3) Which state management technique did you choose and why?**  
**Rajan:** "We used `Provider`. It's straightforward and perfect for managing global app state like our `ThemeProvider`. It allowed us to instantly react to user settings, toggling the entire app's color scheme between light and dark without manually rebuilding deep widget trees."

**(Q6) Explain your local data structure.**  
**Rajan:** "Our database runs on SQLite. We have two main tables: `challenges` for the core habit definitions (with columns for name, frequency, and goal), and `completions`, which acts as a relational log table storing the timestamped records every time a user checks off a task."

**(Q7) How are CRUD operations implemented and validated in your app?**  
**Rajan:** "CRUD operations are encapsulated in a Singleton `DatabaseHelper` class. When a user creates a challenge, we validate the form—ensuring the name isn't empty and the goal is a positive integer. If valid, we insert it into SQLite and immediately refresh the dashboard state."

**(Q9) How were responsibilities divided, and how did you ensure fair technical ownership?**  
**Rajan:** "Michael and I divided the work across vertical slices of the app. I focused heavily on the database models, Provider state, and CRUD logic, while Michael focused on widget composition, the UI/UX flows, and the data visualization integrations. We reviewed each other's code to ensure we both understood the full stack."

**(Q11) How did you decide what to include in README and technical documentation for maintainability?**  
**Rajan:** "We focused on onboarding. The README clearly maps out our app architecture, folder structure, database schema, and edge cases. This ensures any developer picking up our GitHub repository can immediately understand how the `services` layer communicates with the `screens` layer."

**Rajan:** "I'll now hand it over to Michael to cover the rest of the technical questions."

**[RAJAN STOPS RECORDING VIDEO 1 HERE]**

---

## 🎙️ VIDEO 2 SCRIPT: MICHAEL IRVING

**[WHAT MICHAEL SHARES ON SCREEN: The PowerPoint Slide 5 right at the beginning, but have VS Code open in the background ready to switch to!]**

**[MICHAEL STARTS RECORDING VIDEO 2 HERE]**

**Michael:**
"Thanks Rajan. As mentioned, I'm Michael Irving, and my role focused on the UI/UX flows and Data Visualization. For my half, I'll cover the UI, performance, workflow questions, and our final feature trace."

**(Q2) How does your widget tree design affect rendering behavior and performance?**  
**Michael:** "We strictly separated our logical components into independent files and used `const` constructors wherever possible. For dynamic areas like the Dashboard, we isolated our lists so only the precise list elements rebuild when data changes, keeping the frame rate high."

**(Q4) Describe one state-flow interaction from user action to UI update in your app.**  
**Michael:** "When a user taps 'Mark as Completed' on a challenge, the UI triggers a method that writes a new record to the `completions` SQLite table. Once the database insertion awaits successfully, we call `setState` to refresh the local UI variables, which instantly updates the progress bar and streak counter on the screen."

**(Q5) How did you make the interface intuitive and responsive across device sizes/orientations?**  
**Michael:** "We utilized flexible layouts, wrapping text inside `Expanded` widgets to prevent overflow on smaller screens. We also applied consistent padding and constrained box sizes for our charts so they scale proportionally whether the app is running on a phone or desktop simulator."

**(Q8) Share one meaningful commit message and explain why it communicates value clearly.**  
**Michael:** "One of our commits in GitHub was `add challenge details with weekly chart and progress screen`. It clearly states the *what* and the *where*, proving that the commit isn't just a generic update, but a milestone that closed out the specific feature for data visualization tracking."

**(Q10) Which SDLC approach best matches your team workflow, and why?**  
**Michael:** "We followed an Agile approach. Because of our tight deadline, we built the core MVP rapidly—the database and basic screens—and then immediately iterated in short sprints to layer on the bonus features like Dark Mode and the fl_chart graphics."

---

### 🔥 THE CODE TRACE (QUESTION 12)

**[ACTION: MICHAEL SWITCHES HIS SCREEN SHARE TO VS CODE]**
**[WHAT MICHAEL OPENS: `challenge_details_screen.dart` and scrolls to around line 70 (where `_markCompleted()` is) and `database_helper.dart` around line 130.]**

**(Q12) Walk through one complete feature trace using your actual code.**  
**Michael:** "To wrap up our presentation, let's trace exactly how a challenge completion happens in the actual code."

*(Michael points to `challenge_details_screen.dart` on his screen)*  
**Michael:** "Right here on the `ChallengeDetailsScreen`, when the user taps the `ElevatedButton` for 'Mark as Completed', it triggers this `_markCompleted()` function at the top. Inside that function, we instantiate a `Completion` object. We then pass that object to our database singleton by calling `_dbHelper.insertCompletion()`."

*(Michael switches his screen to show `database_helper.dart`)*  
**Michael:** "If we jump over to our DatabaseHelper class, you can see that function executes a raw SQLite `insert` command into the `completions` table using the challenge ID and current timestamp. Once that promise completes successfully..."

*(Michael switches back to `challenge_details_screen.dart`)*  
**Michael:** "...we return to our screen code and call `_loadData()`. This hits the database again to recalculate the user's streaks and refresh the weekly `fl_chart` widget so the user immediately sees their updated progress bar fill up on screen.

And that concludes our presentation for Campus Challenge. On behalf of Rajan and myself from Team U30, thank you for watching!"

**[MICHAEL STOPS RECORDING VIDEO 2 HERE]**
