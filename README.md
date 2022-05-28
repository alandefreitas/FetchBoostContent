# FetchBoostContent

> CMake FetchContent for Boost libraries

[![FetchBoostContent](docs/img/banner.png)](https://alandefreitas.github.io/FetchBoostContent/)

<!--[abstract -->

<br/>

- CMake FetchContent enables build scripts to download and populate the current project with a dependency at configure time. This feature does not work with Boost (sub-)libraries because of transitive dependencies and the way their CMake script rely on the main Boost project.
- The Boost libraries are widely useful and useful to most applications. A version of FetchContent that works for Boost libraries allows developers to (i) provide a fallback option when a Boost installation is not found locally, (ii) download only the required Boost (sub-)libraries required for a single project, (iii) experiment with single Boost libraries, and (iv) and facilitate cross-compiling with CMake.
- A subset of these features can only be obtained nowadays via package managers, which represent a different level of CMake integration, and does not automatically extend these benefits to end users not using the same package manager. This is a problem for library developers relying on Boost, since most end users still don't rely on package managers.
- This repository provides a version of FetchContent that works for Boost (sub-)libraries. When a library is populated, only its internal Boost dependencies are scanned and fetched. The functions are adapted to return or include all dependencies in their appropriate order without fetching the whole Boost super-project.

<br/>

[![Build Status](https://img.shields.io/github/workflow/status/alandefreitas/FetchBoostContent/Build?event=push&label=Build&logo=Github-Actions)](https://github.com/alandefreitas/FetchBoostContent/actions?query=workflow%3ABuild+event%3Apush)
[![Latest Release](https://img.shields.io/github/release/alandefreitas/FetchBoostContent.svg?label=Download)](https://GitHub.com/alandefreitas/FetchBoostContent/releases/)
[![Documentation](https://img.shields.io/website-up-down-green-red/http/alandefreitas.github.io/FetchBoostContent.svg?label=Documentation)](https://alandefreitas.github.io/FetchBoostContent/)
[![Discussions](https://img.shields.io/website-up-down-green-red/http/alandefreitas.github.io/FetchBoostContent.svg?label=Discussions)](https://github.com/alandefreitas/FetchBoostContent/discussions)

<br/>

<!-- https://github.com/bradvin/social-share-urls -->
[![Facebook](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+Facebook&logo=facebook)](https://www.facebook.com/sharer/sharer.php?t=FetchBoostContent&u=https://github.com/alandefreitas/FetchBoostContent/)
[![QZone](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+QZone&logo=qzone)](http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=https://github.com/alandefreitas/FetchBoostContent/&title=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries&summary=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![Weibo](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+Weibo&logo=sina-weibo)](http://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=https://github.com/alandefreitas/FetchBoostContent/&title=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries&summary=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![Reddit](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+Reddit&logo=reddit)](http://www.reddit.com/submit?url=https://github.com/alandefreitas/FetchBoostContent/&title=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?label=Share+on+Twitter&style=social)](https://twitter.com/intent/tweet?text=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries&url=https://github.com/alandefreitas/FetchBoostContent/&hashtags=Task,Programming,Cpp,Async)
[![LinkedIn](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+LinkedIn&logo=linkedin)](https://www.linkedin.com/shareArticle?mini=false&url=https://github.com/alandefreitas/FetchBoostContent/&title=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![WhatsApp](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+WhatsApp&logo=whatsapp)](https://api.whatsapp.com/send?text=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries:+https://github.com/alandefreitas/FetchBoostContent/)
[![Line.me](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+Line.me&logo=line)](https://lineit.line.me/share/ui?url=https://github.com/alandefreitas/FetchBoostContent/&text=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![Telegram.me](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+Telegram.me&logo=telegram)](https://telegram.me/share/url?url=https://github.com/alandefreitas/FetchBoostContent/&text=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)
[![HackerNews](https://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Share+on+HackerNews&logo=y-combinator)](https://news.ycombinator.com/submitlink?u=https://github.com/alandefreitas/FetchBoostContent/&t=FetchBoostContent:%20FetchContent%20for%20Boost%20Libraries)

<br/>

<!--] -->

<br/>

<h2>

[READ THE DOCUMENTATION FOR A QUICK START AND EXAMPLES](https://alandefreitas.github.io/FetchBoostContent/)

[![FetchBoostContent](https://upload.wikimedia.org/wikipedia/commons/2/2a/Documentation-plain.svg)](https://alandefreitas.github.io/FetchBoostContent/)

</h2>


