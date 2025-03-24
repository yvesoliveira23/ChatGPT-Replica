# ChatGPT Replica iOS Application

## Overview

The ChatGPT Replica iOS application is designed to provide a seamless chat experience by leveraging the ChatGPT API. This application allows users to send and receive messages in real-time, replicating the functionality of a chat interface powered by AI.

## Features

- User-friendly chat interface
- Real-time messaging with reactive data streams
- Integration with the ChatGPT API for intelligent responses
- Accessibility features to ensure usability for all users
- Reactive programming with RxSwift for efficient state management

## Requirements

- Xcode 12 or later
- iOS 14.0 or later
- Swift 5.0 or later
- RxSwift 6.5.0 or later

## Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yvesoliveira23/ChatGPT-Replica.git
   cd ChatGPT-Replica/iOSApp
   ```

2. **Open the Xcode Project**

   - Open `ChatGPTReplica.xcodeproj` in Xcode.

3. **Install Dependencies**

   - The project uses Swift Package Manager to manage dependencies including RxSwift.
   - Dependencies should be resolved automatically when opening the project in Xcode.
   - If not, go to File > Swift Packages > Resolve Package Versions.

4. **Configure API Key**

   - Obtain your ChatGPT API key and configure it in the `ChatService.swift` file to enable communication with the backend.

5. **Run the Application**

   - Select a simulator or a physical device and click the Run button in Xcode.

## Usage

- Launch the application and start chatting with the AI.
- Type your message in the input field and hit send to receive a response.

## Best Practices

- Follow Apple's Human Interface Guidelines for design and user experience.
- Ensure accessibility features are implemented for users with disabilities.
- Maintain clean and modular code for better maintainability and readability.

## Architecture

The application follows a clean architecture pattern with MVVM and reactive programming principles:

- **Models**: Core data structures
- **Views**: SwiftUI components that render the UI
- **ViewModels**: Connect views with services and manage state using RxSwift
- **Services**: Handle business logic and API communication

RxSwift is used for:

- Reactive data binding between layers
- Efficient handling of asynchronous operations
- Streamlined error handling
- Clean unidirectional data flow

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
