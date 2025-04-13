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
![Screenshot 2025-04-12 143218](https://github.com/user-attachments/assets/4a14877f-4cc5-4bf3-8b9b-9b1895e9b185)


🎨 Role-Based Interfaces
Separate screens for students and librarians, with their own navigation bars and pages.

🧑‍🎓 Student Features
Home Screen with search functionality for books and authors.

![Screenshot 2025-04-12 143323](https://github.com/user-attachments/assets/691bfe5f-89bc-4dc0-b762-37c999ef72fb)

Bookshelf with a list of currently borrowed books, showing:

Book title, cover, status

Issue and return dates

Automatic fine calculation (coming soon)

![Screenshot 2025-04-12 143614](https://github.com/user-attachments/assets/fa9c48ff-f90d-4b8c-9435-3da3885f0b85)


Notifications for due dates and library updates.

Profile Page to view and update personal details and password.

![Screenshot 2025-04-12 143652](https://github.com/user-attachments/assets/3d995cb6-122d-4733-967a-c38020285f32)


📚 Subject & Genre Browsing
Tab-based Subjects Screen for browsing:

Educational (e.g., Science, History)

Novels (e.g., Mystery, Fantasy)

Journals (e.g., Medical, Business)

Integrated search bar to dynamically filter subjects and book titles.

![Screenshot 2025-04-12 143354](https://github.com/user-attachments/assets/15a5a5ba-ade5-497c-8dc4-ed9276ed7d43)


🧑‍🏫 Librarian Features
Home Dashboard for quick access to actions.

Students Page with approval options for new registrants.

Books Page to:

Add new books

Update or delete existing books

Return Books Page to:

Return Borrowed Books

Profile Page with librarian info and account management tools.
![Screenshot 2025-04-13 185840](https://github.com/user-attachments/assets/577c9ecc-aa25-40cd-9561-5e0d2d3a425b)


🔁 Borrowing Logic
A student can:

Borrow a maximum of 5 books at a time(Customizable)

Borrow a book only once at a time

Borrow requests go through a borrow_requests collection with real-time status tracking.

🧱 Tech Stack
Flutter (Dart) – Cross-platform app development

Firebase (Firestore, Auth) – Backend and database

Custom UI Design – Role-based themes, tabbed navigation, and animations
