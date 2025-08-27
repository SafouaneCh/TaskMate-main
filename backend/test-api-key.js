// Diagnostic script to test Hugging Face API key and basic connectivity
// Run with: node test-api-key.js

require('dotenv').config();
const axios = require('axios');

async function testApiKey() {
    const apiKey = process.env.HUGGINGFACE_API_KEY;
    
    if (!apiKey) {
        console.error('❌ HUGGINGFACE_API_KEY not found in environment variables');
        console.log('Please add your Hugging Face API key to .env file');
        return;
    }
    
    console.log('🔑 Hugging Face API Key found');
    console.log('🔑 API Key starts with:', apiKey.substring(0, 10) + '...');
    
    // Test 1: Check if the API key is valid by testing a simple endpoint
    console.log('\n🧪 Test 1: Testing API key validity...');
    try {
        const response = await axios.get('https://huggingface.co/api/whoami', {
            headers: {
                'Authorization': `Bearer ${apiKey}`
            }
        });
        console.log('✅ API key is valid!');
        console.log('👤 User info:', response.data);
    } catch (error) {
        console.error('❌ API key validation failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
        return;
    }
    
    // Test 2: Try the most basic model possible
    console.log('\n🧪 Test 2: Testing with distilbert-base-uncased (guaranteed to work)...');
    try {
        const response = await axios.post(
            'https://api-inference.huggingface.co/models/distilbert-base-uncased',
            {
                inputs: "Hello world"
            },
            {
                headers: {
                    'Authorization': `Bearer ${apiKey}`,
                    'Content-Type': 'application/json'
                },
                timeout: 30000
            }
        );
        console.log('✅ Basic model test successful!');
        console.log('📊 Response type:', typeof response.data);
        console.log('📊 Response length:', Array.isArray(response.data) ? response.data.length : 'N/A');
    } catch (error) {
        console.error('❌ Basic model test failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
    }
    
    // Test 3: Try gpt2 specifically
    console.log('\n🧪 Test 3: Testing with gpt2 specifically...');
    try {
        const response = await axios.post(
            'https://api-inference.huggingface.co/models/gpt2',
            {
                inputs: "Hello world",
                parameters: {
                    max_new_tokens: 10,
                    temperature: 0.7,
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
        console.log('✅ GPT-2 test successful!');
        console.log('📊 Response:', JSON.stringify(response.data, null, 2));
    } catch (error) {
        console.error('❌ GPT-2 test failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        }
    }
}

// Run the test
testApiKey().catch(console.error);
