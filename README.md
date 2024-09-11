# Data Storage

> [!WARNING]
> **Data Storage** is still in _development_ and in an `BETA` phase (versions from _0.1.0a_ to _0.4.0a_ were in **ALPHA**, version from _0.5.0b_ are in **BETA** phase).
> 
> Due to this the app could be unstable (less than an Alpha). I recommend to do backup of your data (at least your collection/Data Storage) using the `Export` function in the settings page, and saving the `.json` file that will be created in a secure location.
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
  - [x] Boolean: true or false (yes/no)
  - [x] (_soon_) Date;
  - [x] (_soon_) Time;
  - [ ] (_soon_) Date&Time: both date and time together;
  - [ ] (_very soon_) Picker: preselected values (only one at a time);
  - [ ] (_very soon_) Map (or dictionaries in programming languages such Python): a data structure that pairs a **key** (_unique_) to **value** (_not unique_). One example could be phonebook that pairs phone numbers to people.
  - [ ] (_soon_) Multipicker: preselected values with one or more possibility.
  - [ ] (_soon_) List: long list of another type.
  - [ ] (_soon_) Accumulator: An accumulator of another type that is more efficient in memory (e.g. in an integer it would increase of the given amount (or decrease if provided a negative number) without store a genuine historic).
  - If you want more types you can just tell me on issue page on GitHub.
- Support to suspend value adding and remind you that you've to complete it.
- (_soon_, _very soon_) Support for adding charts for each value.
- (_soon_) Support for adding charts for more value.

## Installing

### Supported Platforms

At the moment the only supported platforms are **Android** and **Linux** (maybe also **BSD based**, I don't try).

The fact this project is built with Dart (and Flutter) makes the program crossplatform and this allow me to add simply other OS. For this in the future I want to add also _Windows 11_ (may also Windows 10) support. Support for the Apple environment (_macOS_,  _iOS_ and _ipadOS_) will pontentially never added because I don't use any of them. However I want to try to add more support, but this will not do soon.

### Install on Android

You can install _**Data Storage**_ by downloading the built [`.apk` in the releases page](https://github.com/lucas27-01/data_storage/releases) or build the project from the source code.

In the future I want to add this application on **F-Droid** (and maybe also _Google Play Store_).

### Install on Linux (from v0.5.0b)

You have to download the zip file **`data_storage_x64_v0-5.0b.zip`** from the [latest release](https://github.com/lucas27-01/data_storage/releases) and then unzip that compressed directory. In this directory open a terminal and then execute the following line (useful to make executable the installer script `install.sh`):
```bash
chmod +x ./install.sh
```
Now you have to install the application executing the `install.sh` executable file (as superuser, root's required):
```bash
sudo ./install.sh
```

At the moment this is the only supported (and simple) method. In the future I want to add `.deb`, `.rpm` file and **pacman package**.

### Install on other platforms

As already written the support for other platfrom doesn't exist officially, but you can still try to build yourself if you know how to do that.

_Any_ bug you will find on platform different from **Android** will not be fixed right away but could be useful for developers (only me now) in the future.

The only method for now to install ***Data Storage*** on other platforms is to build the source code on your own. Because I don't support this method (due to instabilities) I will never add a guide for compiling source code. Instead you could follow the [official Flutter Guide](https://docs.flutter.dev/get-started/editor?tab=vscode).

## How to use

_Soon_