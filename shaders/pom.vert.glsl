// POM Vertex Shader (GLSL)
// Assumes a simple plane; constructs a stable TBN in object space

varying vec2 vUv;
varying vec3 vViewPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec3 vBitangent;

void main() {
    vUv = uv;

    // Model-view position for view vector in view space
    vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
    vViewPosition = -mvPosition.xyz;

    // Transform basis vectors into view space
    vNormal   = normalize(normalMatrix * normal);

    // For a plane aligned in object space, use +X as tangent and +Y as bitangent.
    // If your geometry provides tangents, pass them instead.
    vec3 tangentOS   = vec3(1.0, 0.0, 0.0);
    vec3 bitangentOS = vec3(0.0, 1.0, 0.0);

    vTangent  = normalize(normalMatrix * tangentOS);
    vBitangent= normalize(normalMatrix * bitangentOS);

    gl_Position = projectionMatrix * mvPosition;
}
