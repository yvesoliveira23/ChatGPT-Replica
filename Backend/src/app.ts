import express from 'express';
import { setChatRoutes } from './routes/chatRoutes';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.json());

// Routes
setChatRoutes(app);

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});