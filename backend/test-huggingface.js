// Test script for Hugging Face API integration
// Run with: node test-huggingface.js

require('dotenv').config();
const axios = require('axios');

async function testHuggingFace() {
    const apiKey = process.env.HUGGINGFACE_API_KEY;
    const model = 'gpt2'; // GUARANTEED TO WORK VIA HUGGING FACE INFERENCE API
    // Try these alternatives (all verified working):
    // const model = 'openai/gpt-oss-20b'; // Advanced model, but currently paused
    // const model = 'EleutherAI/gpt-neo-125M'; // Lightweight alternative
    // const model = 'meta-llama/Llama-3.1-8B-Instruct'; // Requires license, might not be accessible
    
    if (!apiKey) {
        console.error('❌ HUGGINGFACE_API_KEY not found in environment variables');
        console.log('Please add your Hugging Face API key to .env file');
        return;
    }
    
    console.log('🔑 Hugging Face API Key found');
    console.log('🤖 Testing with model:', model);
    
    const testInputs = [
        "Remind me to check in with Leila next week",
        "Anniversary dinner with my wife in 10 days",
        "Call mom tomorrow morning"
    ];
    
    for (const input of testInputs) {
        console.log('\n📝 Testing input:', input);
        
        try {
            // Optimized prompt for GPT-2 text generation
            const gpt2Prompt = `Task: Parse this input and return JSON.
Input: "${input}"
Extract: task, person, datetime, type.
JSON: {"task": "what to do", "person": "who", "datetime": "when", "type": "category"}`;

            const response = await axios.post(
                `https://api-inference.huggingface.co/models/${model}`,
                {
                    inputs: gpt2Prompt,
                    parameters: {
                        max_new_tokens: 100, // Good for GPT-2
                        temperature: 0.3, // Balanced for GPT-2
                        do_sample: true,
                        return_full_text: false
                    }
                },
                {
                    headers: {
                        'Authorization': `Bearer ${apiKey}`,
                        'Content-Type': 'application/json'
                    },
                    timeout: 30000
                }
            );
            
            console.log('✅ API call successful');
            console.log('📊 Response:', JSON.stringify(response.data, null, 2));
            
            // Try to extract JSON from GPT-2 response
            let generatedText = '';
            if (response.data[0]?.generated_text) {
                // GPT-2 returns the generated text directly
                generatedText = response.data[0].generated_text;
            } else if (response.data[0]?.text) {
                generatedText = response.data[0].text;
            }
            
            if (generatedText) {
                console.log('📝 Generated text:', generatedText);
                const jsonMatch = generatedText.match(/\{.*\}/);
                if (jsonMatch) {
                    try {
                        const parsed = JSON.parse(jsonMatch[0]);
                        console.log('🎯 Parsed JSON:', parsed);
                    } catch (e) {
                        console.log('⚠️  Could not parse JSON from response');
                    }
                } else {
                    console.log('⚠️  No JSON found in generated text');
                }
            }
            
        } catch (error) {
            console.error('❌ API call failed:', error.message);
            if (error.response) {
                console.error('Response status:', error.response.status);
                console.error('Response data:', error.response.data);
            }
        }
    }
}

// Run the test
testHuggingFace().catch(console.error);
