# Library-Management-System-Using-Flutter-and-Firebase


📚 Library Management System — Project Overview
The Library Management System is a modern, user-friendly mobile application built using Flutter and integrated with Firebase for seamless real-time data management. It serves as a digital companion for both students and librarians to manage, browse, and maintain a physical library's book inventory.

👥 User Roles
Students can browse books, manage their borrowed list, and get notifications.

Librarians can manage inventory, approve borrow/return requests, and handle users.

✅ Key Features
🔐 Authentication
Firebase Auth integrated login for both students and librarians.

Registration with librarian approval workflow.

🎨 Role-Based Interfaces
Separate screens for students and librarians, with their own navigation bars and pages.

🧑‍🎓 Student Features
Home Screen with search functionality for books and authors.

Bookshelf with a list of currently borrowed books, showing:

Book title, cover, status

Issue and return dates

Automatic fine calculation (coming soon)

Notifications for due dates and library updates.

Profile Page to view and update personal details and password.

📚 Subject & Genre Browsing
Tab-based Subjects Screen for browsing:

Educational (e.g., Science, History)

Novels (e.g., Mystery, Fantasy)

Journals (e.g., Medical, Business)

Integrated search bar to dynamically filter subjects and book titles.

🔎 Live Search Functionality
Search subjects or book titles directly in the Subjects screen.

Filtered results are displayed instantly in a list format.

🧑‍🏫 Librarian Features
Home Dashboard for quick access to actions.

Students Page with approval options for new registrants.

Books Page to:

Add new books

Update or delete existing books

Return Books Page to:

Return Borrowed Books

Profile Page with librarian info and account management tools.

🔁 Borrowing Logic
A student can:

Borrow a maximum of 5 books at a time(Customizable)

Borrow a book only once at a time

Borrow requests go through a borrow_requests collection with real-time status tracking.

🧱 Tech Stack
Flutter (Dart) – Cross-platform app development

Firebase (Firestore, Auth) – Backend and database

Custom UI Design – Role-based themes, tabbed navigation, and animations
