#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uReveal;

out vec4 fragColor;

float hash21(vec2 point) {
  point = fract(point * vec2(123.34, 456.21));
  point += dot(point, point + 45.32);
  return fract(point.x * point.y);
}

vec2 hash22(vec2 point) {
  float seed = hash21(point);
  return vec2(seed, hash21(point + seed + 17.17));
}

void main() {
  vec2 pixel = FlutterFragCoord().xy;
  vec2 uv = pixel / max(uSize, vec2(1.0));
  float time = uTime * 6.28318530718;
  vec2 loopOffset = vec2(cos(time), sin(time));

  float cloudA = sin(
    uv.x * 5.2 + uv.y * 2.4 + dot(loopOffset, vec2(0.72, 0.31))
  );
  float cloudB = cos(
    uv.x * 2.7 - uv.y * 4.3 + dot(loopOffset, vec2(-0.27, 0.63))
  );
  float cloudC = sin(
    (uv.x + uv.y) * 7.1 + dot(loopOffset, vec2(0.19, -0.42))
  );
  float cloud = 0.5 + 0.5 * (cloudA * 0.46 + cloudB * 0.34 + cloudC * 0.20);

  vec3 pearl = vec3(0.82, 0.84, 0.84);
  vec3 blush = vec3(0.92, 0.79, 0.73);
  vec3 blue = vec3(0.70, 0.78, 0.85);
  vec3 gold = vec3(0.91, 0.86, 0.60);

  vec3 color = mix(pearl, blush, smoothstep(0.18, 0.76, cloud));
  color = mix(color, blue, smoothstep(0.50, 1.05, uv.y + cloudB * 0.12));
  float goldBloom = smoothstep(0.74, 1.0, uv.x + cloudA * 0.09) *
      smoothstep(0.22, 0.90, uv.y);
  color = mix(color, gold, goldBloom * 0.52);

  vec2 cellSize = vec2(5.5);
  vec2 cell = floor(pixel / cellSize);
  vec2 local = fract(pixel / cellSize);
  vec2 starPosition = 0.14 + hash22(cell) * 0.72;
  float starSeed = hash21(cell + 31.7);
  float starDistance = length(local - starPosition);
  float starShape = smoothstep(0.18, 0.018, starDistance);
  float starExists = smoothstep(0.78, 0.96, starSeed);
  float twinkleFrequency = 1.0 + floor(starSeed * 3.0);
  float twinkle = 0.48 +
      0.52 * sin(time * twinkleFrequency + starSeed * 31.0);
  float tinyStars = starShape * starExists * twinkle;

  vec2 largeCell = floor(pixel / 64.0);
  vec2 largeLocal = fract(pixel / 64.0);
  vec2 largePosition = 0.28 + hash22(largeCell + 9.3) * 0.44;
  float largeSeed = hash21(largeCell + 83.1);
  vec2 delta = abs(largeLocal - largePosition);
  float largeFrequency = 1.0 + floor(largeSeed * 2.0);
  float largePulse = pow(
    0.5 + 0.5 * sin(time * largeFrequency + largeSeed * 24.0),
    3.0
  );
  float radiusX = mix(0.12, 0.18, hash21(largeCell + 18.6));
  float radiusY = radiusX * mix(1.15, 1.55, hash21(largeCell + 52.4));
  float breathe = 0.92 + largePulse * 0.08;
  vec2 normalizedDelta = delta / (vec2(radiusX, radiusY) * breathe);
  float fourPointField = pow(normalizedDelta.x, 0.55) +
      pow(normalizedDelta.y, 0.55);
  float fourPointCore = 1.0 - smoothstep(0.76, 1.02, fourPointField);
  float fourPointGlow = 1.0 - smoothstep(0.82, 1.42, fourPointField);
  float largeExists = smoothstep(0.75, 0.96, largeSeed);
  float largeStars = (fourPointCore + fourPointGlow * 0.24) *
      largeExists * (0.30 + largePulse * 0.70);

  float grain = hash21(floor(pixel * 1.4));
  float glitterFrequency = 2.0 + floor(grain * 3.0);
  float glitterPulse = pow(
    0.5 + 0.5 * sin(time * glitterFrequency + grain * 37.0),
    5.0
  );
  float glitter = smoothstep(0.94, 1.0, grain) * glitterPulse * 0.42;
  float sparkle = clamp(tinyStars * 0.82 + largeStars + glitter, 0.0, 1.0);

  float alpha = uReveal * (0.66 + sparkle * 0.30);
  vec3 finalColor = mix(color, vec3(1.0), sparkle * 0.94);
  fragColor = vec4(finalColor * alpha, alpha);
}
