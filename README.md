## Code Exercise

### Structure
The instructions were to use one codebase for two applications that share common logic. The repo contains the two projects as well as a common business logic framework.

This repo also utilizes a “3rd-party” netoworking framework. Both framework dependencies are included using Cocoapods dependency management.

#### simpsonsviewer
This is the project that retrieves The Simpsons characters and displays the results in a list. Tapping on a list item shows the detail of that character including the name, photo and a brief description.

#### wireviewer
This project does the sam as above except it retrieves characters from the show The Wire.

#### characterviewer
This is a framework that contains the logic to retrieve the data as well as all the UI used in both *simpsonsviewer* and *wireviewer*. Both projects simply initialize the *characterviewer* with a defined settings object for their respective shows.

This dependency is pulled in as a development pod using Cocoapods. Since this is a local project, there is no need to add it to a separate repo although that can easily be done.

### 3rd-Party dependencies
I use the term ‘3rd-party’ here somewhat loosely. This dependency is actually my own open-source project.

#### BuckarooBanzai
This is a networking layer that I created and have updated to use modern concurrency idioms. The documentations is not complete as I have only recently been able to start detailing its use. Feel free to look it over as well as part of how I design my projects.

https://github.com/BonEvil/BuckarooBanzai