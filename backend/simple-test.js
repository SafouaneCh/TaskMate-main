// Very simple test to check API key
// Run with: node simple-test.js

require('dotenv').config();

console.log('🔍 Simple API Key Test');
console.log('=======================');
console.log('');

// Check if the key exists
const apiKey = process.env.HUGGINGFACE_API_KEY;
if (!apiKey) {
    console.log('❌ HUGGINGFACE_API_KEY not found in .env file');
    return;
}

console.log('✅ API Key found in .env file');
console.log('📏 Length:', apiKey.length);
console.log('🔑 Starts with:', apiKey.substring(0, 10) + '...');
console.log('🔑 Ends with:', '...' + apiKey.substring(apiKey.length - 4));
console.log('');

// Test if it's the same old key
if (apiKey.startsWith('hf_AnVQbjp')) {
    console.log('⚠️  WARNING: This looks like the OLD API key!');
    console.log('   You need to update your .env file with the NEW token');
    return;
}

console.log('✅ This looks like a NEW API key');
console.log('');

// Try a very simple test
const axios = require('axios');

console.log('🧪 Testing with Hugging Face API...');
axios.get('https://huggingface.co/api/whoami', {
    headers: {
        'Authorization': `Bearer ${apiKey}`
    }
})
.then(response => {
    console.log('✅ SUCCESS! API key is working');
    console.log('👤 User:', response.data.name);
    console.log('📧 Email:', response.data.email);
})
.catch(error => {
    console.log('❌ FAILED:', error.message);
    if (error.response) {
        console.log('Status:', error.response.status);
        console.log('Data:', error.response.data);
    }
});





