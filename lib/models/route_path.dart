class MyRoutePath {
  final String? id;
  final bool isUnknown;
  final bool isRegisterPage;
  final bool isLoginPage;
  final bool isHomePage;
  final bool isAddStoryPage;

  MyRoutePath.home()
      : id = null,
        isHomePage = true,
        isUnknown = false,
        isRegisterPage = false,
        isLoginPage = false,
        isAddStoryPage = false;

  MyRoutePath.login()
      : id = null,
        isLoginPage = true,
        isUnknown = false,
        isRegisterPage = false,
        isHomePage = false,
        isAddStoryPage = false;

  MyRoutePath.register()
      : id = null,
        isRegisterPage = true,
        isUnknown = false,
        isLoginPage = false,
        isHomePage = false,
        isAddStoryPage = false;

  MyRoutePath.storyDetail(this.id)
      : isUnknown = false,
        isRegisterPage = false,
        isLoginPage = false,
        isHomePage = false,
        isAddStoryPage = false;

  MyRoutePath.addStory()
      : id = null,
        isAddStoryPage = true,
        isUnknown = false,
        isRegisterPage = false,
        isLoginPage = false,
        isHomePage = false;

  MyRoutePath.unknown()
      : id = null,
        isUnknown = true,
        isRegisterPage = false,
        isLoginPage = false,
        isHomePage = false,
        isAddStoryPage = false;

  bool get isStoryDetailPage => id != null && !isUnknown;
}
