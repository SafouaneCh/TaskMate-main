// Debug script to check API key reading
// Run with: node debug-key.js

require('dotenv').config();

console.log('🔍 Debugging API Key Reading...');
console.log('');

// Check if the key exists
if (!process.env.HUGGINGFACE_API_KEY) {
    console.log('❌ HUGGINGFACE_API_KEY not found in environment variables');
    return;
}

const apiKey = process.env.HUGGINGFACE_API_KEY;

console.log('📏 Key length:', apiKey.length);
console.log('🔑 Key starts with:', apiKey.substring(0, 10) + '...');
console.log('🔑 Key ends with:', '...' + apiKey.substring(apiKey.length - 4));
console.log('');

// Check for common issues
console.log('🔍 Checking for common issues:');
console.log('Has spaces at start:', apiKey.startsWith(' '));
console.log('Has spaces at end:', apiKey.endsWith(' '));
console.log('Has quotes at start:', apiKey.startsWith('"') || apiKey.startsWith("'"));
console.log('Has quotes at end:', apiKey.endsWith('"') || apiKey.endsWith("'"));
console.log('Contains newlines:', apiKey.includes('\n') || apiKey.includes('\r'));
console.log('');

// Show the raw key (be careful with this in production)
console.log('🔑 Raw key (first 20 chars):', JSON.stringify(apiKey.substring(0, 20)));
console.log('🔑 Raw key (last 20 chars):', JSON.stringify(apiKey.substring(apiKey.length - 20)));

// Test the key format
if (apiKey.startsWith('hf_')) {
    console.log('✅ Key format looks correct (starts with hf_)');
} else {
    console.log('❌ Key format incorrect (should start with hf_)');
}

if (apiKey.length >= 30) {
    console.log('✅ Key length looks correct (>= 30 characters)');
} else {
    console.log('❌ Key length too short (< 30 characters)');
}
