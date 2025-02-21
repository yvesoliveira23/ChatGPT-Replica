import { Router } from 'express';
import { ChatController } from '../controllers/chatController';
import { ChatService } from '../services/chatService';
import { Application, Request, Response } from 'express';
import dotenv from 'dotenv';

dotenv.config();

const router = Router();

const apiKey = process.env.OPENAI_API_KEY || '';
const chatService = new ChatService(apiKey);
const chatController = new ChatController(chatService);

interface IChatController {
    sendMessage(req: Request, res: Response): Promise<void>;
    receiveMessage(req: Request, res: Response): Promise<void>;
}

export function setChatRoutes(app: Application): void {
    app.use('/api/chat', router);

    router.post('/send', chatController.sendMessage.bind(chatController));
    router.get('/receive', chatController.receiveMessage.bind(chatController));
}