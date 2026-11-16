# photoapp (Tagger)

An iOS app for tagging photos in your library. Built on Apple's Photos framework (starting from Apple's sample photo-browser code), it shows your albums and photos in a grid and lets you attach coloured tags to photos. A filter menu narrows the grid to photos with particular tags.

The tagging logic lives in a small cross-platform C++ engine in `code/Engine/` (tag manager, strings, streams, file system, lists) with Catch unit tests, which also build on Windows through the Visual Studio project in `code/VisualStudio/`. The Objective-C++ UI is in `code/TaggerApp/`, with fastlane setup in `code/fastlane/`. `examples/` holds an earlier asset-picker prototype.
