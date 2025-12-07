#version 330 core

layout(location = 0) in vec3 position;
layout(location = 1) in vec3 normal;
layout(location = 2) in vec2 texcoord;  // Try to read texcoords

uniform mat4 mvp;
uniform mat4 matModel;
uniform mat3 matNormal;

out vec3 fragPosition;
out vec3 fragNormal;
out vec2 fragTexCoord;

void main() {
    fragPosition = vec3(matModel * vec4(position, 1.0));
    fragNormal = normalize(matNormal * normal);
    fragTexCoord = texcoord;
    gl_Position = mvp * vec4(position, 1.0);
}