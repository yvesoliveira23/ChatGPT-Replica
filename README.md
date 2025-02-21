# ChatGPT Replica

This project is a full-stack application that replicates the functionality of ChatGPT. It consists of a backend built with TypeScript and Express, and an iOS application developed in Swift. The application allows users to send and receive messages using the ChatGPT API.

## Project Structure

```bash
ChatGPT-Replica
├── Backend
│   ├── src
│   │   ├── app.ts
│   │   ├── controllers
│   │   │   └── chatController.ts
│   │   ├── routes
│   │   │   └── chatRoutes.ts
│   │   └── services
│   │       └── chatService.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── README.md
├── iOSApp
│   ├── ChatGPTReplica.xcodeproj
│   ├── ChatGPTReplica
│   │   ├── AppDelegate.swift
│   │   ├── SceneDelegate.swift
│   │   ├── ViewControllers
│   │   │   └── ChatViewController.swift
│   │   ├── Models
│   │   │   └── ChatMessage.swift
│   │   ├── Views
│   │   │   └── ChatView.swift
│   │   ├── Services
│   │   │   └── ChatService.swift
│   │   └── Resources
│   │       └── Assets.xcassets
│   └── README.md
└── README.md
```

## Getting Started

### Prerequisites

- Node.js and npm for the backend
- Xcode for the iOS application
- A valid ChatGPT API key

### Backend Setup

1. Navigate to the `Backend` directory.
2. Install the dependencies:

   ```bash
   npm install
   ```

3. Create a `.env` file and add your ChatGPT API key:

   ```bash
   CHATGPT_API_KEY=your_api_key_here
   ```

4. Start the backend server:

   ```bash
   npm start
   ```

### iOS Application Setup

1. Open the `ChatGPTReplica.xcodeproj` file in Xcode.
2. Ensure that the project settings are configured correctly.
3. Build and run the application on a simulator or a physical device.

## Usage

- The iOS application provides a user interface for chatting with the ChatGPT model.
- Users can send messages and receive responses in real-time.

## Best Practices

This project adheres to Apple's guidelines for accessibility and clean code principles. Ensure to follow these practices while contributing to the project.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
