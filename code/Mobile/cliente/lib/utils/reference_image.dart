import 'dart:convert';
import 'dart:typed_data';

const _dataImagePrefix = 'data:image/';

class ReferenceContent {
  const ReferenceContent({this.text, this.imageDataUri});

  final String? text;
  final String? imageDataUri;

  bool get hasText => text != null && text!.trim().isNotEmpty;
  bool get hasImage => isReferenceImage(imageDataUri);
}

String? buildReferencePayload({String? text, String? imageDataUri}) {
  final cleanText = text?.trim();
  final hasText = cleanText != null && cleanText.isNotEmpty;
  final hasImage = isReferenceImage(imageDataUri);

  if (!hasText && !hasImage) {
    return null;
  }

  return jsonEncode({
    if (hasText) 'texto': cleanText,
    if (hasImage) 'imagem': imageDataUri,
  });
}

ReferenceContent parseReferenceContent(String? value) {
  final raw = value?.trim() ?? '';

  if (raw.isEmpty) {
    return const ReferenceContent();
  }

  try {
    final data = jsonDecode(raw);

    if (data is Map<String, dynamic>) {
      return ReferenceContent(
        text: data['texto'] as String?,
        imageDataUri: data['imagem'] as String?,
      );
    }
  } on FormatException {
    // Legacy records may be plain text or only a data image.
  }

  if (isReferenceImage(raw)) {
    return ReferenceContent(imageDataUri: raw);
  }

  return ReferenceContent(text: raw);
}

bool isReferenceImage(String? value) {
  return value?.startsWith(_dataImagePrefix) ?? false;
}

Uint8List? decodeReferenceImage(String? dataUri) {
  if (!isReferenceImage(dataUri)) {
    return null;
  }

  final commaIndex = dataUri!.indexOf(',');
  if (commaIndex == -1 || commaIndex == dataUri.length - 1) {
    return null;
  }

  try {
    return base64Decode(dataUri.substring(commaIndex + 1));
  } on FormatException {
    return null;
  }
}
