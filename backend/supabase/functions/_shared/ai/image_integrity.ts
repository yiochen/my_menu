export interface ImageIntegrityResult {
  valid: boolean;
  reasons: string[];
  width?: number;
  height?: number;
}

export function inspectImageIntegrity(
  bytes: Uint8Array,
  contentType: string,
): ImageIntegrityResult {
  const dimensions = contentType === "image/png"
    ? pngDimensions(bytes)
    : contentType === "image/jpeg"
    ? jpegDimensions(bytes)
    : null;
  if (dimensions == null) {
    return { valid: false, reasons: ["invalid_image_integrity"] };
  }
  if (
    dimensions.width < 256 || dimensions.height < 256 ||
    dimensions.width > 8192 || dimensions.height > 8192 ||
    bytes.length > 20 * 1024 * 1024
  ) {
    return {
      valid: false,
      reasons: ["invalid_image_dimensions"],
      ...dimensions,
    };
  }
  try {
    const decoded = contentType === "image/png"
      ? decodePng(bytes)
      : jpeg.decode(bytes, { useTArray: true, formatAsRGBA: false });
    if (
      decoded.width !== dimensions.width || decoded.height !== dimensions.height
    ) {
      return { valid: false, reasons: ["invalid_image_integrity"] };
    }
  } catch {
    return { valid: false, reasons: ["invalid_image_integrity"] };
  }
  return { valid: true, reasons: [], ...dimensions };
}

function pngDimensions(bytes: Uint8Array) {
  const signature = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
  if (
    bytes.length < 33 ||
    !signature.every((value, index) => bytes[index] === value) ||
    readUint32(bytes, 8) !== 13 ||
    String.fromCharCode(...bytes.subarray(12, 16)) !== "IHDR"
  ) return null;
  const width = readUint32(bytes, 16);
  const height = readUint32(bytes, 20);
  let offset = 8;
  let sawEnd = false;
  while (offset + 12 <= bytes.length) {
    const length = readUint32(bytes, offset);
    const end = offset + 12 + length;
    if (end > bytes.length) return null;
    const type = String.fromCharCode(...bytes.subarray(offset + 4, offset + 8));
    if (type === "IEND") {
      sawEnd = length === 0 && end === bytes.length;
      break;
    }
    offset = end;
  }
  return sawEnd && width > 0 && height > 0 ? { width, height } : null;
}

function jpegDimensions(bytes: Uint8Array) {
  if (
    bytes.length < 16 || bytes[0] !== 0xff || bytes[1] !== 0xd8 ||
    bytes[bytes.length - 2] !== 0xff || bytes[bytes.length - 1] !== 0xd9
  ) return null;
  let offset = 2;
  while (offset + 4 < bytes.length) {
    while (bytes[offset] === 0xff) offset += 1;
    const marker = bytes[offset++];
    if (marker === 0xda || marker === 0xd9) break;
    if (marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) continue;
    const length = (bytes[offset] << 8) | bytes[offset + 1];
    if (length < 2 || offset + length > bytes.length) return null;
    if (
      marker === 0xc0 || marker === 0xc1 || marker === 0xc2 ||
      marker === 0xc3 || marker === 0xc5 || marker === 0xc6 ||
      marker === 0xc7 || marker === 0xc9 || marker === 0xca ||
      marker === 0xcb || marker === 0xcd || marker === 0xce || marker === 0xcf
    ) {
      if (length < 7) return null;
      const height = (bytes[offset + 3] << 8) | bytes[offset + 4];
      const width = (bytes[offset + 5] << 8) | bytes[offset + 6];
      return width > 0 && height > 0 ? { width, height } : null;
    }
    offset += length;
  }
  return null;
}

function readUint32(bytes: Uint8Array, offset: number) {
  return ((bytes[offset] << 24) >>> 0) +
    (bytes[offset + 1] << 16) +
    (bytes[offset + 2] << 8) + bytes[offset + 3];
}
import { decode as decodePng } from "npm:fast-png@7.0.1";
import jpeg from "npm:jpeg-js@0.4.4";
