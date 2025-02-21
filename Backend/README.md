# ChatGPT Replica Backend

This is the backend service for the ChatGPT Replica application. It is built using Node.js and Express, providing an API for the iOS application to interact with the ChatGPT service.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [API Endpoints](#api-endpoints)
- [Contributing](#contributing)
- [License](#license)

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yvesoliveira23/ChatGPT-Replica.git
   cd ChatGPT-Replica/Backend
   ```

2. Install the dependencies:

   ```bash
   npm install
   ```

3. Set up your environment variables. Create a `.env` file in the root of the `Backend` directory and add your ChatGPT API key:

   ```bash
   CHATGPT_API_KEY=your_api_key_here
   ```

## Usage

To start the backend server, run:

```bash
npm start
```

The server will run on `http://localhost:3000` by default.

## API Endpoints

- `POST /api/chat/send`: Send a message to the ChatGPT service.
- `GET /api/chat/receive`: Receive a response from the ChatGPT service.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
