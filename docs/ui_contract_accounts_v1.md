# Account Screens Contract v1

Screen: Profile

Object: ProfileHeader
- title: String
- subtitle: String

Object: AccountSummary
- displayName: String
- email: String
- authProviderSummary: String

Object: AccountPreference
- calendarDisplayMode: String

Object: AccountCallToAction
- label: String
- route: String

Screen: Sign In

Object: SignInForm
- email: String
- password: String

Screen: Sign Up

Object: SignUpForm
- displayName: String
- email: String
- password: String
- calendarDisplayMode: String

Screen: Forgot Password

Object: ForgotPasswordForm
- email: String

Screen: Edit Profile

Object: EditProfileForm
- displayName: String
- calendarDisplayMode: String
