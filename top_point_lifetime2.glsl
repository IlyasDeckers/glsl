// Lifetime-Only Feedback Shader
// Input 0: Your source (fresh pointcloud positions)
// Input 1: Feedback (after your noise/displace chain)

layout(location = 0) out vec4 fragColor;

uniform float uDecay;    // e.g., 0.98
uniform float uMaxAge;   // frames until dead, e.g., 60

void main()
{
    vec2 uv = vUV.st;
    
    vec4 source = texture(sTD2DInputs[0], uv);
    vec4 feedback = texture(sTD2DInputs[1], uv);
    
    // Decode age from alpha
    float age = feedback.a * uMaxAge;
    age += 1.0;
    
    // Decay feedback
    vec3 feedbackColor = feedback.rgb * uDecay;
    
    // Hard cutoff
    if (age >= uMaxAge)
    {
        feedbackColor = vec3(0.0);
        age = uMaxAge;
    }
    
    // Source overrides feedback
    float sourceStrength = max(source.r, max(source.g, source.b));
    
    vec3 finalColor;
    float finalAge;
    
    if (sourceStrength > 0.01)
    {
        finalColor = source.rgb;
        finalAge = 0.0;
    }
    else
    {
        finalColor = feedbackColor;
        finalAge = age;
    }
    
    fragColor = TDOutputSwizzle(vec4(finalColor, finalAge / uMaxAge));
}
