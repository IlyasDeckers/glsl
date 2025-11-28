// Feedback Loop with Pixel Lifetime
// Input 0: Your source (pointcloud, shapes, whatever)
// Input 1: Feedback from this same GLSL TOP (use a Feedback TOP)

layout(location = 0) out vec4 fragColor;

uniform float uDecay;        // Per-frame multiplier, e.g., 0.98
uniform float uMaxAge;       // Frames until forced black, e.g., 60
uniform float uNoiseAmount;  // UV displacement amount, e.g., 0.005
uniform float uNoiseSpeed;   // Animation speed, e.g., 0.5
uniform float uTime;         // absTime.seconds

void main()
{
    vec2 uv = vUV.st;
    
    // Add noise-based displacement to UV for the feedback sample
    // This creates the dissolve/drift effect
    vec2 noiseUV = uv * 3.0 + uTime * uNoiseSpeed;
    vec2 offset = vec2(
        TDPerlinNoise(vec3(noiseUV, 0.0)),
        TDPerlinNoise(vec3(noiseUV + 100.0, 0.0))
    ) * uNoiseAmount;
    
    // Sample the feedback with displaced UVs
    vec4 feedback = texture(sTD2DInputs[1], uv + offset);
    
    // Sample fresh input (no displacement)
    vec4 source = texture(sTD2DInputs[0], uv);
    
    // --- LIFETIME TRACKING ---
    // We store age in the alpha channel
    // Fresh source pixels reset age to 0
    // Feedback pixels increment age each frame
    
    float feedbackAge = feedback.a * uMaxAge;  // Decode age from alpha
    feedbackAge += 1.0;                         // Increment age
    
    // Apply decay to feedback RGB
    vec3 feedbackColor = feedback.rgb * uDecay;
    
    // Hard cutoff: if too old, kill it completely
    if (feedbackAge >= uMaxAge)
    {
        feedbackColor = vec3(0.0);
        feedbackAge = uMaxAge;
    }
    
    // Combine: source pixels override feedback
    // Check if source has meaningful content (brightness threshold)
    float sourceStrength = max(source.r, max(source.g, source.b));
    
    vec3 finalColor;
    float finalAge;
    
    if (sourceStrength > 0.01)
    {
        // Fresh pixel from source - reset age
        finalColor = source.rgb;
        finalAge = 0.0;
    }
    else
    {
        // Use decayed feedback
        finalColor = feedbackColor;
        finalAge = feedbackAge;
    }
    
    // Encode age back into alpha (normalized 0-1)
    float encodedAge = finalAge / uMaxAge;
    
    fragColor = TDOutputSwizzle(vec4(finalColor, encodedAge));
}
