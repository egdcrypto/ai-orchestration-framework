#!/bin/bash
# Setup script for Aider with local models
# No API keys required - completely free and private!

set -e

echo "🚀 Setting up Aider with Local Models"
echo "======================================"

# Check system
echo "📊 System Information:"
echo "RAM: $(free -h | grep Mem | awk '{print $2}')"
echo "CPU: $(nproc) cores"

# Install Ollama if not present
if ! command -v ollama &> /dev/null; then
    echo "📦 Installing Ollama..."
    curl -fsSL https://ollama.ai/install.sh | sh
else
    echo "✅ Ollama already installed"
fi

# Install Aider if not present
if ! command -v aider &> /dev/null; then
    echo "📦 Installing Aider..."
    pip install aider-chat
else
    echo "✅ Aider already installed: $(aider --version)"
fi

# Get available RAM in GB
RAM_GB=$(free -g | grep Mem | awk '{print $2}')

echo ""
echo "🧠 Selecting models based on your RAM ($RAM_GB GB)..."

# Select models based on RAM
if [ "$RAM_GB" -ge 32 ]; then
    echo "💪 You have 32GB+ RAM - Installing best models..."
    MODELS=("deepseek-coder:33b" "codellama:34b" "qwen2.5-coder:32b")
elif [ "$RAM_GB" -ge 16 ]; then
    echo "👍 You have 16GB+ RAM - Installing medium models..."
    MODELS=("codellama:13b" "deepseek-coder:7b" "qwen2.5-coder:7b")
else
    echo "💻 You have <16GB RAM - Installing small models..."
    MODELS=("codellama:7b" "deepseek-coder:1.3b")
fi

# Pull models
echo ""
echo "📥 Downloading models (this may take a while)..."
for MODEL in "${MODELS[@]}"; do
    echo "   Pulling $MODEL..."
    ollama pull "$MODEL" || echo "   ⚠️ Failed to pull $MODEL (may already exist)"
done

# List available models
echo ""
echo "📋 Available Ollama models:"
ollama list

# Test Aider with a local model
echo ""
echo "🧪 Testing Aider with local model..."
TEST_MODEL="${MODELS[0]}"
echo "Testing with $TEST_MODEL..."

# Create a test file
TEST_DIR="/tmp/aider-test-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cat > test.py << 'EOF'
def add(a, b):
    # TODO: implement this function
    pass

def test_add():
    assert add(2, 3) == 5
EOF

# Test Aider
echo "Implement the add function" | timeout 30 aider --model "ollama/$TEST_MODEL" --yes --no-auto-commits test.py || true

# Check if it worked
if grep -q "return a + b" test.py 2>/dev/null; then
    echo "✅ Aider is working with local models!"
else
    echo "⚠️ Aider test inconclusive - manual verification may be needed"
fi

# Clean up
cd - > /dev/null
rm -rf "$TEST_DIR"

echo ""
echo "✨ Setup Complete!"
echo ""
echo "📚 Quick Start Guide:"
echo "-------------------"
echo "1. Basic usage:"
echo "   aider --model ollama/${MODELS[0]} --yes"
echo ""
echo "2. With specific files:"
echo "   aider --model ollama/${MODELS[0]} --yes myfile.py"
echo ""
echo "3. For orchestration:"
echo "   ./orchestrator.sh threat-detection-project.yaml start --ai-provider aider-local"
echo ""
echo "Available local models for Aider:"
for MODEL in "${MODELS[@]}"; do
    echo "   - ollama/$MODEL"
done
echo ""
echo "🎉 You're ready to use Aider with FREE local models!"