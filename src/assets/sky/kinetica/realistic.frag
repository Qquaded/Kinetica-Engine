#version 330 core

in vec3 fragPosition;
in vec3 fragNormal;

out vec4 finalColor;

uniform vec3 globalAmbient;
uniform vec3 dirLightDir;
uniform vec3 dirLightColor;
uniform vec4 colDiffuse;

void main() {
    vec3 normal = normalize(fragNormal);
    vec3 color = globalAmbient;
    float diff = max(dot(normal, normalize(dirLightDir)), 0.0);
    color += diff * dirLightColor;
    
    // Just use color without texture
    finalColor = vec4(color, 1.0) * colDiffuse;
}