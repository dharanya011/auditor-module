import 'package:flutter/material.dart';

enum AuditStatus { verified, pending, issue, critical, correctionRequested, inReview, closed }

enum Severity { low, medium, high, critical }

class AuditKPI {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  const AuditKPI({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

class ModuleProgress {
  final String name;
  final int verified;
  final int pending;
  final int issues;
  final double percentage;

  const ModuleProgress({
    required this.name,
    required this.verified,
    required this.pending,
    required this.issues,
    required this.percentage,
  });
}

class AuditActivity {
  final String id;
  final String title;
  final String module;
  final String timestamp;
  final String status;
  final IconData icon;
  final Color iconColor;
  final String auditor;

  const AuditActivity({
    required this.id,
    required this.title,
    required this.module,
    required this.timestamp,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.auditor,
  });
}

class CriticalIssue {
  final String id;
  final String title;
  final String priority;
  final String code;
  final String department;
  final String date;

  const CriticalIssue({
    required this.id,
    required this.title,
    required this.priority,
    required this.code,
    required this.department,
    required this.date,
  });
}

class StudentAuditRecord {
  final String registerNo;
  final String name;
  final String department;
  final int semester;
  final double cgpa;
  final double attendance;
  final String photoUrl;
  final String status;
  final List<RecordGroupStatus> groupStatuses;

  StudentAuditRecord({
    required this.registerNo,
    required this.name,
    required this.department,
    required this.semester,
    required this.cgpa,
    required this.attendance,
    required this.photoUrl,
    required this.status,
    required this.groupStatuses,
  });
}

class RecordGroupStatus {
  final String groupName;
  final String status; // Verified, Discrepancy, Pending
  final String details;

  RecordGroupStatus({
    required this.groupName,
    required this.status,
    required this.details,
  });
}

class AssignmentRecord {
  final String id;
  final String studentRegNo;
  final String studentName;
  final String title;
  final String subject;
  final String submissionDate;
  final int marksObtained;
  final int totalMarks;
  final String evidenceFile;
  final bool isMissingFile;
  final bool isLate;
  final bool isDuplicate;
  final String status;

  AssignmentRecord({
    required this.id,
    required this.studentRegNo,
    required this.studentName,
    required this.title,
    required this.subject,
    required this.submissionDate,
    required this.marksObtained,
    required this.totalMarks,
    required this.evidenceFile,
    this.isMissingFile = false,
    this.isLate = false,
    this.isDuplicate = false,
    required this.status,
  });
}

class MarksAuditEntry {
  final String id;
  final String studentRegNo;
  final String studentName;
  final String subjectCode;
  final String subjectName;
  final int facultyEntry;
  final int deptRecord;
  final int examRecord;
  final int finalResult;
  final bool isMismatch;
  final String mismatchReason;
  final String status;

  MarksAuditEntry({
    required this.id,
    required this.studentRegNo,
    required this.studentName,
    required this.subjectCode,
    required this.subjectName,
    required this.facultyEntry,
    required this.deptRecord,
    required this.examRecord,
    required this.finalResult,
    required this.isMismatch,
    this.mismatchReason = '',
    required this.status,
  });
}

class FacultyReportRecord {
  final String id;
  final String facultyName;
  final String department;
  final String reportType;
  final String academicYear;
  final String regulation;
  final int semester;
  final double reportedAttendance;
  final double actualAttendance;
  final int syllabusCompletionPercent;
  final int mentoringSessionsLogged;
  final bool hasConflict;
  final String conflictDetails;
  final String status;

  FacultyReportRecord({
    required this.id,
    required this.facultyName,
    required this.department,
    required this.reportType,
    required this.academicYear,
    this.regulation = 'R2023',
    this.semester = 1,
    required this.reportedAttendance,
    required this.actualAttendance,
    required this.syllabusCompletionPercent,
    required this.mentoringSessionsLogged,
    this.hasConflict = false,
    this.conflictDetails = '',
    required this.status,
  });
}

class QuestionPaperRecord {
  final String id;
  final String courseCode;
  final String courseTitle;
  final String regulation;
  final String department;
  final int semester;
  final String academicYear;
  final bool bloomTaxonomyCompliant;
  final bool syllabusMapped;
  final bool hodApproved;
  final bool coeApproved;
  final String status;

  QuestionPaperRecord({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.regulation,
    required this.department,
    this.semester = 1,
    this.academicYear = '2025 - 2026',
    required this.bloomTaxonomyCompliant,
    required this.syllabusMapped,
    required this.hodApproved,
    required this.coeApproved,
    required this.status,
  });
}

class ResearchRecord {
  final String id;
  final String title;
  final String authors;
  final String type; // Journal Article, Conference Paper, Book Chapter, Other
  final String doi;
  final String journalName;
  final String indexing; // Scopus, Web of Science, Scopus / Web of Science, Other
  final String year;
  final bool metadataMatch;
  final bool duplicateFlag;
  final String status;

  // Faculty & Department Information
  final String organization;
  final String department;
  final String facultyName;
  final String description;

  // Document Information
  final String documentName;
  final String documentType;
  final String documentSize;
  final String documentStatus; // Not Uploaded, Uploaded, Under Examination, Verified, Needs Correction

  // Auditor Verification & Remarks
  final Map<String, String> verificationChecklist;
  final String auditorRemarks;

  ResearchRecord({
    required this.id,
    required this.title,
    required this.authors,
    required this.type,
    required this.doi,
    required this.journalName,
    required this.indexing,
    required this.year,
    required this.metadataMatch,
    this.duplicateFlag = false,
    required this.status,
    this.organization = 'KSR College of Engineering',
    this.department = 'Computer Science & Engineering',
    this.facultyName = 'Dr. R. Kumar',
    this.description = 'Research paper submitted for academic performance and ERP audit verification.',
    this.documentName = 'paper_kumar.pdf',
    this.documentType = 'PDF Document',
    this.documentSize = '1.24 MB',
    this.documentStatus = 'Uploaded',
    Map<String, String>? verificationChecklist,
    this.auditorRemarks = '',
  }) : verificationChecklist = verificationChecklist ?? {
          'Paper Title': 'Pending',
          'Authors': 'Pending',
          'Faculty Affiliation': 'Pending',
          'Department': 'Pending',
          'Publication Details': 'Pending',
          'DOI': 'Pending',
          'Journal / Conference': 'Pending',
          'Indexing Information': 'Pending',
        };
}

class EvidenceItem {
  final String evidenceId;
  final String recordId;
  final String recordType;
  final String uploadedBy;
  final String uploadDate;
  final String documentType;
  final String version;
  final String fileName;
  final String fileSize;
  final String status;

  EvidenceItem({
    required this.evidenceId,
    required this.recordId,
    required this.recordType,
    required this.uploadedBy,
    required this.uploadDate,
    required this.documentType,
    required this.version,
    required this.fileName,
    required this.fileSize,
    required this.status,
  });
}

class AuditCaseItem {
  final String caseId;
  final String title;
  final String category;
  final String targetRecordId;
  final String severity;
  final String assignedTo;
  final String lifecycleStage; // Detected -> Under Review -> Correction Requested -> Corrected -> Re-verified -> Closed
  final String createdDate;
  final String description;

  AuditCaseItem({
    required this.caseId,
    required this.title,
    required this.category,
    required this.targetRecordId,
    required this.severity,
    required this.assignedTo,
    required this.lifecycleStage,
    required this.createdDate,
    required this.description,
  });
}

class AIAnomalyItem {
  final String id;
  final String anomalyTitle;
  final String category;
  final String severity;
  final String detectionReason;
  final String recordReference;
  final String recommendation;
  final String status;

  AIAnomalyItem({
    required this.id,
    required this.anomalyTitle,
    required this.category,
    required this.severity,
    required this.detectionReason,
    required this.recordReference,
    required this.recommendation,
    required this.status,
  });
}

class AuditLogItem {
  final String id;
  final String timestamp;
  final String auditorName;
  final String ipAddress;
  final String action;
  final String recordId;
  final String details;

  AuditLogItem({
    required this.id,
    required this.timestamp,
    required this.auditorName,
    required this.ipAddress,
    required this.action,
    required this.recordId,
    required this.details,
  });
}
