# SpendingTrackerVapor

🔐 Authentication & User Management

Method    Endpoint    Description
POST    /users/register    Register a new user (sends email verification link)
GET    /users/verify    Verify email with token (e.g., /users/verify?token=xyz)
POST    /users/login    Log in and receive a token (only if email is verified)

💸 Spending Entries (Authenticated)

Method    Endpoint    Description
GET    /spendings    Get all spending entries for the user
POST    /spendings    Add a new spending entry
PUT    /spendings/:id    Update a specific spending
DELETE    /spendings/:id    Delete a specific spending
