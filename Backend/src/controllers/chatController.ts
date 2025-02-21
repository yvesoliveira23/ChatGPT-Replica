import { ChatService } from "../services/chatService";
import { Request, Response } from 'express';

export class ChatController {
    private chatService: ChatService;

    constructor(chatService: ChatService) {
        this.chatService = chatService;
    }

    public async sendMessage(req: Request, res: Response): Promise<void> {
        try {
            const { message } = req.body;
            console.log('Received message to send:', message);
            const response = await this.chatService.getChatResponse(message);
            await this.chatService.saveMessage(message);
            res.status(200).json({ response });
        } catch (error) {
            console.error('Error in sendMessage:', error);
            res.status(500).json({ error: (error as Error).message });
        }
    }

    public async receiveMessage(req: Request, res: Response): Promise<void> {
        try {
            console.log('Received request to get messages');
            const messages = await this.chatService.getMessages();
            res.status(200).json({ messages });
        } catch (error) {
            console.error('Error in receiveMessage:', error);
            res.status(500).json({ error: 'Internal Server Error' });
        }
    }
}