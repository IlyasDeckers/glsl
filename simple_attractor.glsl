layout(location = 0) out vec4 fragColor;

// Define attractor position (you can also use uniforms to animate these)
uniform vec2 uAttractor1;  // Set on Vectors page, e.g., (0.5, 0.5)
uniform float uRadius;      // Falloff radius, e.g., 0.3
uniform float uIntensity;   // Brightness multiplier, e.g., 2.0

void main()
{
    // Get normalized coordinates (0-1 range)
    vec2 uv = vUV.st;
    
    // Calculate distance from this pixel to the attractor
    float dist = distance(uv, uAttractor1);
    
    // Create falloff - closer = brighter
    // smoothstep gives a nice smooth falloff
    float attraction = 1.0 - smoothstep(0.0, uRadius, dist);
    
    // Apply intensity
    attraction *= uIntensity;
    
    // Output as grayscale (or color it however you like)
    vec4 color = vec4(vec3(attraction), 1.0);
    
    fragColor = TDOutputSwizzle(color);
}
