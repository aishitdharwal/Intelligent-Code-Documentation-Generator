# Phase 2: Breaking Scenarios

## 🎯 Objective

Intentionally break the Phase 1 POC by scaling it beyond its design limits. This teaches you what happens when production systems face real-world challenges without proper engineering.

## 💥 Breaking Tests

### Test 1: Large Single File (10,000+ lines)

**Scenario:** Process a massive Python file with 10,000+ lines

**What to Expect:**
- ⏱️ **Timeout Risk**: Lambda 15-minute limit
- 💰 **High Cost**: Single file could cost ₹100-200
- 🐌 **Slow Processing**: 5-10 minutes per file
- 🧠 **Context Window Issues**: Approaching Claude's token limits

**How to Break:**
```python
# Create a large test file
python tests/test_data/generators/create_large_file.py --lines 10000

# Try to process it
python src/phase1_poc/lambda_function.py --file tests/test_data/large_repo/large_file.py
```

**Expected Failure:**
```
Error: Request timeout after 900 seconds
Cost so far: ₹180
Tokens used: ~180,000
```

**Why It Breaks:**
- No chunking strategy
- Entire file sent in one API call
- Single-threaded processing
- No progress tracking

---

### Test 2: Large Repository (50,000 lines, 100+ files)

**Scenario:** Process an entire repository with 100 files totaling 50,000 lines

**What to Expect:**
- 💸 **Cost Explosion**: ₹4,000+ for single run
- 🕐 **Extremely Slow**: 2-3 hours total
- ⚠️ **Rate Limits**: 429 errors from Claude API
- 💥 **Lambda Timeout**: Can't process all files in one invocation

**How to Break:**
```python
# Clone a real repository
git clone https://github.com/psf/requests.git tests/test_data/large_repo/requests

# Try to process it (IT WILL FAIL)
python tests/integration/test_large_repo.py
```

**Expected Failures:**
```
File 1/100: ✓ Success (₹40, 30s)
File 2/100: ✓ Success (₹35, 28s)
File 3/100: ✓ Success (₹42, 32s)
...
File 15/100: ✗ Failed - Rate limit exceeded (429)
...
File 30/100: ✗ Failed - Lambda timeout
Total cost before crash: ₹1,200
Files completed: 29/100 (29%)
```

**Why It Breaks:**
- No rate limiting implementation
- No retry logic with exponential backoff
- Sequential processing (one file at a time)
- No caching (re-processing identical files)
- No cost caps or budgets
- No progress persistence (crash = start over)

---

### Test 3: Repeated Processing (Same Repo 10 Times)

**Scenario:** Process the same repository 10 times (simulating development workflow)

**What to Expect:**
- 💰 **Wasted Money**: ₹400 × 10 = ₹4,000 for identical work
- 🔄 **No Caching**: Every run costs the same
- ⏱️ **Wasted Time**: 30 minutes × 10 = 5 hours

**How to Break:**
```bash
# Run the same test 10 times
for i in {1..10}; do
    python src/phase1_poc/lambda_function.py --file tests/test_data/small_repo/calculator.py
done
```

**Expected Result:**
```
Run 1: ✓ ₹20 (30s)
Run 2: ✓ ₹20 (30s) <- Same cost! No cache!
Run 3: ✓ ₹20 (30s) <- Same cost! No cache!
...
Run 10: ✓ ₹20 (30s)
Total: ₹200 for the same file 10 times
With caching: Should be ₹20 (first run) + ₹0 (cached) × 9 = ₹20
Money wasted: ₹180 (90% savings possible)
```

**Why It Breaks:**
- No caching layer
- No file hash checking
- No DynamoDB or Redis cache
- Every identical file costs the same

---

### Test 4: Concurrent Requests (10 Files Simultaneously)

**Scenario:** Try to process 10 files at the same time

**What to Expect:**
- 🚫 **Rate Limit Errors**: Claude API has request-per-minute limits
- ❌ **Multiple Failures**: 7-8 out of 10 requests fail
- 🔄 **No Retry Logic**: Failed requests are lost

**How to Break:**
```python
# Process 10 files concurrently
python tests/integration/test_concurrent.py --files 10
```

**Expected Result:**
```
Starting 10 concurrent requests...

File 1: ✓ Success (₹25, 20s)
File 2: ✓ Success (₹30, 22s)
File 3: ✗ Failed - 429 Rate Limit Exceeded
File 4: ✓ Success (₹28, 21s)
File 5: ✗ Failed - 429 Rate Limit Exceeded
File 6: ✗ Failed - 429 Rate Limit Exceeded
File 7: ✗ Failed - 429 Rate Limit Exceeded
File 8: ✓ Success (₹32, 23s)
File 9: ✗ Failed - 429 Rate Limit Exceeded
File 10: ✗ Failed - 429 Rate Limit Exceeded

Success Rate: 40%
Total Cost: ₹115 (but 60% of work wasted)
```

**Why It Breaks:**
- No rate limiting implementation
- No request queue
- No exponential backoff
- No retry mechanism
- All requests fire simultaneously

---

### Test 5: Memory Intensive File (Complex AST)

**Scenario:** Process a file with extremely complex nested structures

**What to Expect:**
- 🧠 **Memory Overflow**: Lambda OOM error
- 📈 **High Memory Usage**: Exceeds 512MB allocation
- 💥 **Crash**: No graceful degradation

**How to Break:**
```python
# Create a deeply nested file
python tests/test_data/generators/create_nested_file.py --depth 100

# Try to process it
python src/phase1_poc/lambda_function.py --file tests/test_data/large_repo/deeply_nested.py
```

**Expected Failure:**
```
Analyzing file...
Building AST...
Error: Lambda ran out of memory
Memory used: 520MB / 512MB
Process killed
```

**Why It Breaks:**
- Fixed 512MB memory allocation
- No memory monitoring
- AST parsing of complex files is memory-intensive
- No streaming or chunking

---

## 📊 Cost Comparison: POC vs Production

| Scenario | POC (Phase 1) | Production (Phase 3) | Savings |
|----------|---------------|---------------------|---------|
| Single file (1,000 lines) | ₹20 | ₹8 | 60% |
| Large file (10,000 lines) | ₹180 | ₹50 | 72% |
| Repository (50,000 lines) | ₹4,000 | ₹240 | **94%** |
| 10 runs of same repo | ₹4,000 | ₹400 | 90% |
| **Monthly (100 repos)** | **₹40,000** | **₹6,000** | **85%** |

---

## 🎓 What You Learn

After experiencing these failures, you'll understand why production systems need:

### 1. **Chunking Strategies**
   - Break large files into manageable pieces
   - Maintain context between chunks
   - Process chunks in parallel

### 2. **Caching Layers**
   - Hash-based file caching
   - TTL-based cache expiration
   - DynamoDB for persistent cache

### 3. **Rate Limiting**
   - Request queues
   - Exponential backoff
   - Respect API quotas

### 4. **Cost Management**
   - Per-request budgets
   - Cost tracking and alerts
   - Optimization opportunities

### 5. **Error Handling**
   - Retry logic with backoff
   - Graceful degradation
   - Detailed error logging

### 6. **Monitoring**
   - CloudWatch metrics
   - Cost per request
   - Success/failure rates
   - Performance tracking

### 7. **Scalability**
   - Parallel processing (ECS)
   - Auto-scaling
   - Load balancing

---

## 🔧 Next Steps

After breaking the system, you'll rebuild it properly in Phase 3 with:

1. ✅ **Intelligent chunking** (2,000 line chunks with overlap)
2. ✅ **DynamoDB caching** (80% cost reduction)
3. ✅ **Rate limiter** with exponential backoff
4. ✅ **Parallel processing** via ECS Fargate
5. ✅ **CloudWatch monitoring** with custom metrics
6. ✅ **Cost tracking** per request
7. ✅ **Error recovery** with retry logic
8. ✅ **Auto-scaling** based on queue depth

---

## 🏃 Running the Breaking Tests

```bash
# Install dependencies
pip install -r requirements.txt

# Set up environment
cp .env.example .env
# Add your ANTHROPIC_API_KEY to .env

# Run breaking tests (WARNING: These will fail and cost money)
python tests/integration/test_breaking_scenarios.py

# Or run specific tests
python tests/integration/test_large_file.py
python tests/integration/test_large_repo.py
python tests/integration/test_concurrent.py
```

**⚠️ Warning:** These tests will actually call the Claude API and incur costs. Budget ₹500-1,000 for testing all scenarios.

---

## 📈 Metrics to Track

As you run these tests, track:

1. **Cost per scenario**
2. **Success rate** (% of files processed)
3. **Processing time** per file
4. **API errors** (count and types)
5. **Memory usage**
6. **Token consumption**

This data will help you understand the improvements in Phase 3.

---

**Remember:** Breaking systems intentionally in a controlled environment is how you learn what NOT to do in production. Every failure here teaches a valuable lesson about production engineering.
