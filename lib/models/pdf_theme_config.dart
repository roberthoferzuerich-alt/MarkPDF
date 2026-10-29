import 'package:flutter/material.dart' show IconData, Icons;
import 'package:pdf/pdf.dart';

enum PdfThemeType {
  modernBusiness,
  academicPaper,
  techDeveloper,
  cleanMinimal,
}

class PdfThemeConfig {
  final PdfThemeType type;
  final String title;
  final String subtitle;
  final IconData icon;

  // Farben für das PDF
  final PdfColor primaryColor;
  final PdfColor secondaryColor;
  final PdfColor textColor;
  final PdfColor textMutedColor;
  final PdfColor tableHeaderBg;
  final PdfColor tableHeaderTextColor;
  final PdfColor tableAltRowBg;
  final PdfColor quoteBorderColor;
  final PdfColor quoteBgColor;
  final PdfColor codeBlockBg;
  final PdfColor codeBlockBorder;
  final PdfColor codeBlockTextColor;
  final PdfColor dividerColor;
  final bool isSerif;
  final double h1BorderWidth;

  const PdfThemeConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.textMutedColor,
    required this.tableHeaderBg,
    required this.tableHeaderTextColor,
    required this.tableAltRowBg,
    required this.quoteBorderColor,
    required this.quoteBgColor,
    required this.codeBlockBg,
    required this.codeBlockBorder,
    required this.codeBlockTextColor,
    required this.dividerColor,
    this.isSerif = false,
    this.h1BorderWidth = 1.5,
  });

  static const PdfThemeConfig modernBusiness = PdfThemeConfig(
    type: PdfThemeType.modernBusiness,
    title: 'Modern Business',
    subtitle: 'Blau & Slate • Elegant für Kunden & Angebote',
    icon: Icons.business_center_outlined,
    primaryColor: PdfColor.fromInt(0xFF1E3A8A), // Royal Blue
    secondaryColor: PdfColor.fromInt(0xFF1E293B), // Slate 800
    textColor: PdfColor.fromInt(0xFF334155), // Slate 700
    textMutedColor: PdfColor.fromInt(0xFF64748B),
    tableHeaderBg: PdfColor.fromInt(0xFF1E3A8A),
    tableHeaderTextColor: PdfColors.white,
    tableAltRowBg: PdfColor.fromInt(0xFFF8FAFC),
    quoteBorderColor: PdfColor.fromInt(0xFF2563EB),
    quoteBgColor: PdfColor.fromInt(0xFFF1F5F9),
    codeBlockBg: PdfColor.fromInt(0xFF0F172A),
    codeBlockBorder: PdfColor.fromInt(0xFF334155),
    codeBlockTextColor: PdfColor.fromInt(0xFFE2E8F0),
    dividerColor: PdfColors.grey300,
    isSerif: false,
    h1BorderWidth: 1.5,
  );

  static const PdfThemeConfig academicPaper = PdfThemeConfig(
    type: PdfThemeType.academicPaper,
    title: 'Academic Paper',
    subtitle: 'Serif-Schrift • Klassisch für Berichte & Arbeiten',
    icon: Icons.school_outlined,
    primaryColor: PdfColor.fromInt(0xFF111827), // Fast Schwarz
    secondaryColor: PdfColor.fromInt(0xFF374151),
    textColor: PdfColor.fromInt(0xFF1F2937),
    textMutedColor: PdfColor.fromInt(0xFF4B5563),
    tableHeaderBg: PdfColor.fromInt(0xFF374151),
    tableHeaderTextColor: PdfColors.white,
    tableAltRowBg: PdfColor.fromInt(0xFFF9FAFB),
    quoteBorderColor: PdfColor.fromInt(0xFF4B5563),
    quoteBgColor: PdfColor.fromInt(0xFFF9FAFB),
    codeBlockBg: PdfColor.fromInt(0xFFF3F4F6),
    codeBlockBorder: PdfColor.fromInt(0xFFD1D5DB),
    codeBlockTextColor: PdfColor.fromInt(0xFF111827),
    dividerColor: PdfColor.fromInt(0xFF9CA3AF),
    isSerif: true,
    h1BorderWidth: 0.8,
  );

  static const PdfThemeConfig techDeveloper = PdfThemeConfig(
    type: PdfThemeType.techDeveloper,
    title: 'Tech & Code',
    subtitle: 'Teal & Terminal • Für Dokumentationen & IT',
    icon: Icons.terminal_outlined,
    primaryColor: PdfColor.fromInt(0xFF0F766E), // Teal Accent
    secondaryColor: PdfColor.fromInt(0xFF134E4A),
    textColor: PdfColor.fromInt(0xFF1E293B),
    textMutedColor: PdfColor.fromInt(0xFF64748B),
    tableHeaderBg: PdfColor.fromInt(0xFF0F766E),
    tableHeaderTextColor: PdfColors.white,
    tableAltRowBg: PdfColor.fromInt(0xFFF0FDFA),
    quoteBorderColor: PdfColor.fromInt(0xFF0D9488),
    quoteBgColor: PdfColor.fromInt(0xFFF0FDFA),
    codeBlockBg: PdfColor.fromInt(0xFF0F172A),
    codeBlockBorder: PdfColor.fromInt(0xFF14B8A6),
    codeBlockTextColor: PdfColor.fromInt(0xFF5EEAD4),
    dividerColor: PdfColor.fromInt(0xFFCCFBF1),
    isSerif: false,
    h1BorderWidth: 2.0,
  );

  static const PdfThemeConfig cleanMinimal = PdfThemeConfig(
    type: PdfThemeType.cleanMinimal,
    title: 'Clean Minimal',
    subtitle: 'Klassisches Schwarz-Weiß • Zeitlos & Schlicht',
    icon: Icons.border_clear_outlined,
    primaryColor: PdfColor.fromInt(0xFF000000), // Tiefschwarz
    secondaryColor: PdfColor.fromInt(0xFF262626),
    textColor: PdfColor.fromInt(0xFF262626),
    textMutedColor: PdfColor.fromInt(0xFF737373),
    tableHeaderBg: PdfColor.fromInt(0xFF262626),
    tableHeaderTextColor: PdfColors.white,
    tableAltRowBg: PdfColor.fromInt(0xFFFAFAFA),
    quoteBorderColor: PdfColor.fromInt(0xFF737373),
    quoteBgColor: PdfColor.fromInt(0xFFFAFAFA),
    codeBlockBg: PdfColor.fromInt(0xFFF5F5F5),
    codeBlockBorder: PdfColor.fromInt(0xFFE5E5E5),
    codeBlockTextColor: PdfColor.fromInt(0xFF171717),
    dividerColor: PdfColor.fromInt(0xFFE5E5E5),
    isSerif: false,
    h1BorderWidth: 1.0,
  );

  static PdfThemeConfig fromType(PdfThemeType type) {
    switch (type) {
      case PdfThemeType.modernBusiness:
        return modernBusiness;
      case PdfThemeType.academicPaper:
        return academicPaper;
      case PdfThemeType.techDeveloper:
        return techDeveloper;
      case PdfThemeType.cleanMinimal:
        return cleanMinimal;
    }
  }

  static const List<PdfThemeConfig> allThemes = [
    modernBusiness,
    academicPaper,
    techDeveloper,
    cleanMinimal,
  ];
}
