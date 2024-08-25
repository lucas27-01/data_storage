# Data Storage

> [!WARNING]
> **Data Storage** is still in _development_ and in an `ALPHA` phase. 
> 
> Due to this the app could be unstable. I recommend to do backup of your data (at least your collection/Data Storage) using the `Export` function in the settings page, and saving the `.json` file that will be created in a secure location.
> For reimporting the data after an error or loss of data you can use the `Import` function always in  the settings page.

A Flutter project that collects data in several types and allow the user to see them as he want.

## Overview 

**Data Storage** is an application to storage data in several type and see them in customizable chart _(soon)_, useful to do statistics due to many statistical information (such as mode, median, mean, etc). All this built with a wonderful graphical toolkit (***Flutter***) and a crossplatform and fast programming language (***Dart***) with many packages.

## Features

- Language Support (_English_, _Italian_)
- Exporting Data: you can export your data (only the collections) in a `.json` file.
- Import Data: you can import a `.json` file for restore your data loss, due to application error, disinstalling the app or installing it on a new phone. 
> [!NOTE]
> **DO NOT EDIT** the exported `.json` file unless you know what you are doing, because this could ruin your own data!
- Support for several type:
  - [x] Integer: non-decimal number,
  - [x] Decimal: number both integer or decimal (double)
  - [x] String: long (or short) list of characters (i.e. a word, a phrase, one character)
  - [ ] (_soon_) Date;
  - [ ] (_soon_) Time;
  - [ ] (_soon_) Date&Time: both date and time together;
  - [ ] (_soon_) Picker: preselected values (only one at a time);
  - [ ] (_soon_) Multipicker: preselected values with one or more possibility.
  - If you want more types you can just tell me on issue page on GitHub.
- (_soon_, _very soon_) Support for adding charts for each value
- (_soon_) Support for adding charts for more value.

## Installing

### Supported Platforms

At the moment the only supported platform is **Android**.

The fact this project is built with Dart (and Flutter) makes the program crossplatform and this allow me to add simply other OS. For this in the future I want to add also _Linux_ and _Windows 11_ (may also Windows 10) support. Support for the Apple environment (_macOS_,  _iOS_ and _ipadOS_) will pontentially never added because I don't use any of them. However I want to try to add more support, but this will not do soon.

### Install on Android

Now _Android_ is the only supported system but this not mean that it's simple to install on it. This because the application is still in alpha.

However it's less difficult than install on other application, because you can download the built [`.apk` in the releases page](https://github.com/lucas27-01/data_storage/releases) or build the project from the source code.

### Install on other platforms

As already written the support for other platfrom doesn't exist officially, but you can still try to build yourself if you know how to do that.

_Any_ bug you will find on platform different from **Android** will not be fixed right away but could be useful for developers (only me now) in the future.

The only method for now to install ***Data Storage*** on other platforms is to build the source code on your own. Because I don't support this method (due to instabilities) I will never add a guide for compiling source code. Instead you could follow the [official Flutter Guide](https://docs.flutter.dev/get-started/editor?tab=vscode).

## How to use

_Soon_