# Neptune's Pride Agent Mobile
A mobile app that simply loads [Neptune's Pride](https://np.ironhelmet.com) in a webview and force-injects the client code from [Neptune's Pride Agent](https://github.com/anicolao/npa) ([Stable Extension](https://chrome.google.com/webstore/detail/neptunes-pride-agent/gpcdekpemhpdcacfnafnflnlakelfefh) | [Alpha Extension](https://chrome.google.com/webstore/detail/neptunes-pride-agent-%CE%AC%CE%BB%CF%86%CE%B1/ndfajnjbmlanogpddbbjbbcoahhomaba)). Note that the injected code is the latest code that exists on the github, and as such, most closely resembles the alpha edition extension.

This is simply a glue project, glueing the two together.

# Why
Mobile browser offerings seem to generally not allow extensions, or some required part of the extension API is missing. I could not get NPA to run on mobile, which made me feel blind when accessing at work or on-the-go. Knowing the basics of how extensions and mobile apps work, I figured I could glue the two together forcibly, thus this project.

# NOTE
This project was created solely for my own use. PRs are welcome, though I don't plan on providing any major level of support. For the most part, this project is provided as-is.
