import * as fs from 'fs/promises';

export class ChatService {

    public async getMessages(): Promise<string[]> {
        const path = './messages.txt';

        try {
            const data = await fs.readFile(path, 'utf-8');
            return data.split('\n').filter((message: string) => message.trim() !== '');
        } catch (err) {
            console.error('Failed to retrieve messages:', err);
            throw new Error('Failed to retrieve messages');
        }
    }

    private apiKey: string;
    private apiUrl: string;

    constructor(apiKey: string) {
        this.apiKey = apiKey;
        this.apiUrl = 'https://api.openai.com/v1/chat/completions';
    }

    public async getChatResponse(message: string): Promise<string> {
        try {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000); // 5 seconds timeout

            console.log('Sending request to ChatGPT API with message:', message);

            const response = await fetch(this.apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.apiKey}`
                },
                body: JSON.stringify({
                    model: 'gpt-3.5-turbo',
                    messages: [{ role: 'user', content: message }]
                }),
                signal: controller.signal
            });

            clearTimeout(timeoutId);

            if (!response.ok) {
                const errorText = await response.text();
                console.error('Failed to fetch response from ChatGPT API:', errorText);
                const errorData = JSON.parse(errorText);
                if (errorData.error && errorData.error.code === 'insufficient_quota') {
                    throw new Error('You have exceeded your quota for the OpenAI API. Please check your plan and billing details.');
                }
                throw new Error('Failed to fetch response from ChatGPT API');
            }

            const data = await response.json();
            console.log('Received response from ChatGPT API:', data);
            return data.choices[0].message.content;
        } catch (error) {
            console.error('Error in getChatResponse:', error);
            if (error instanceof Error) {
                throw new Error(error.message);
            } else {
                throw new Error('An unknown error occurred');
            }
        }
    }

    public async saveMessage(message: string): Promise<void> {
        const path = './messages.txt';

        try {
            await fs.appendFile(path, message + '\n');
            console.log('Message saved:', message);
        } catch (err) {
            console.error('Failed to save message:', err);
            throw new Error('Failed to save message');
        }
    }
}