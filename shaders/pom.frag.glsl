// Interior Mapping Fragment Shader (GLSL)
// For equirectangular room textures - ray-box intersection
// Adapted for Three.js (Y-up)

uniform sampler2D map;        // Equirectangular room texture
uniform float depthScale;     // Room depth (how far back the walls are)
uniform vec3 flipVector;      // Flip vector for coordinate adjustment
uniform vec3 rotationDeg;     // Euler rotation in degrees (X, Y, Z)

varying vec2 vUv;
varying vec3 vViewPosition;
varying vec3 vNormal;
varying vec3 vTangent;
varying vec3 vBitangent;

#define PI 3.14159265359

// Rotation matrices
mat3 rotateX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, -s,
        0.0, s, c
    );
}

mat3 rotateY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, 0.0, s,
        0.0, 1.0, 0.0,
        -s, 0.0, c
    );
}

mat3 rotateZ(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, -s, 0.0,
        s, c, 0.0,
        0.0, 0.0, 1.0
    );
}

// Convert 3D direction to equirectangular UV
vec2 dirToEquirectangular(vec3 dir) {
    float u = atan(dir.x, dir.z) / (2.0 * PI) + 0.5;
    float v = asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5;
    return vec2(u, v);
}

void main() {
    // Build TBN matrix - standard construction
    vec3 N = normalize(vNormal);
    vec3 T = normalize(vTangent);
    vec3 B = normalize(vBitangent);
    mat3 tbn = mat3(T, B, N);

    // ===== BLENDER NODE LOGIC (exact translation) =====
    
    // 1. Incoming vector - view direction in tangent space
    vec3 viewDirWorld = normalize(vViewPosition);
    vec3 incoming = normalize(transpose(tbn) * -viewDirWorld);
    
    // 2. Absolute of incoming
    vec3 absIncoming = abs(incoming);
    
    // 3. UV -> Fraction -> Multiply by 2 -> Subtract 1
    vec2 fracUV = fract(vUv);
    vec2 scaledUV = fracUV * 2.0 - 1.0;
    
    // 4. Combine XYZ: Blender uses (X, 1.0, Z) where Y=1 is the depth
    //    In Three.js tangent space: X=right, Y=up, Z=normal(depth)
    //    So we put depthScale in Z, UV.x in X, UV.y in Y
    vec3 uvVec = vec3(scaledUV.x, scaledUV.y, depthScale);
    
    // 5. Interior mapping: find where ray hits the box walls
    vec3 rayDir = incoming;
    
    // Ray starts at window position (scaledUV defines where on window we are)
    // The back wall is at Z = depthScale, side walls at X,Y = ±1
    // We compute t for each wall: t = (wall - pos) / dir
    
    // For the back wall (Z = depthScale), starting from Z = 0:
    float tBack = depthScale / max(abs(rayDir.z), 0.001);
    
    // For side walls X = ±1, starting from X = scaledUV.x:
    float tRight = (1.0 - scaledUV.x) / max(rayDir.x, 0.001);
    float tLeft = (-1.0 - scaledUV.x) / min(rayDir.x, -0.001);
    float tX = rayDir.x > 0.0 ? tRight : tLeft;
    if (abs(rayDir.x) < 0.001) tX = 1e10;
    
    // For top/bottom walls Y = ±1, starting from Y = scaledUV.y:
    float tTop = (1.0 - scaledUV.y) / max(rayDir.y, 0.001);
    float tBottom = (-1.0 - scaledUV.y) / min(rayDir.y, -0.001);
    float tY = rayDir.y > 0.0 ? tTop : tBottom;
    if (abs(rayDir.y) < 0.001) tY = 1e10;
    
    // Take the smallest positive t (first wall hit)
    float t = min(min(abs(tX), abs(tY)), abs(tBack));
    t = max(t, 0.001);
    
    // Calculate hit position
    vec3 rayPos = vec3(scaledUV.x, scaledUV.y, 0.0);
    vec3 roomPos = rayPos + rayDir * t;
    
    // 8. Multiply by flip vector
    vec3 flipped = roomPos * flipVector;
    
    // 9. Vector Rotate: Euler angles
    float radX = radians(rotationDeg.x);
    float radY = radians(rotationDeg.y);
    float radZ = radians(rotationDeg.z);
    mat3 rot = rotateZ(radZ) * rotateY(radY) * rotateX(radX);
    vec3 rotated = rot * flipped;
    
    // 10. Convert to equirectangular UV and sample
    vec2 finalUV = dirToEquirectangular(normalize(rotated));
    
    vec4 color = texture2D(map, finalUV);
    gl_FragColor = color;
}
