import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/models.dart';
import '../providers/audit_state.dart';

class AddResearchPaperDialog extends StatefulWidget {
  final AuditState state;

  const AddResearchPaperDialog({super.key, required this.state});

  @override
  State<AddResearchPaperDialog> createState() => _AddResearchPaperDialogState();
}

class _AddResearchPaperDialogState extends State<AddResearchPaperDialog> {
  final _formKey = GlobalKey<FormState>();

  // Organizations
  final List<String> _organizations = [
    'KSR College of Engineering',
    'KSR Institute for Engineering and Technology',
  ];
  late String _selectedOrganization;

  // Departments
  final Map<String, List<String>> _departmentFaculty = {
    'Computer Science and Engineering': ['Dr. R. Kumar', 'Dr. P. Anand', 'Prof. K. Suresh'],
    'Information Technology': ['Dr. S. Meena', 'Ms. R. Divya', 'Dr. V. Rajesh'],
    'Electronics and Communication Engineering': ['Dr. A. Priya', 'Prof. M. Rajan', 'Dr. C. Kavitha'],
    'Mechanical Engineering': ['Dr. M. Arun', 'Dr. N. Balamurugan', 'Prof. T. Venkatesh'],
  };

  late String _selectedDepartment;
  late String _selectedFaculty;

  // Paper Details Controllers
  final _titleController = TextEditingController();
  final _authorsController = TextEditingController();
  final _journalController = TextEditingController();
  final _doiController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Journal Article';
  final List<String> _types = [
    'Journal Article',
    'Conference Paper',
    'Book Chapter',
    'Other',
  ];

  String _selectedYear = '2025';
  final List<String> _years = ['2026', '2025', '2024', '2023'];

  String _selectedIndexing = 'Scopus';
  final List<String> _indexings = [
    'Scopus',
    'Web of Science',
    'Scopus / Web of Science',
    'Other',
  ];

  // Document Upload State
  bool _hasUploadedFile = false;
  String _fileName = '';
  String _fileSize = '';
  final String _fileType = 'PDF Document';

  @override
  void initState() {
    super.initState();
    _selectedOrganization = _organizations.first;
    _selectedDepartment = _departmentFaculty.keys.first;
    _selectedFaculty = _departmentFaculty[_selectedDepartment]!.first;
    _authorsController.text = _selectedFaculty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorsController.dispose();
    _journalController.dispose();
    _doiController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _simulateFileUpload() {
    // File upload will be connected to backend in STEP 2.
    // For now, show that upload is pending implementation.
    widget.state.showToast('Document upload will be available when backend is connected.');
  }

  void _removeUploadedFile() {
    setState(() {
      _hasUploadedFile = false;
      _fileName = '';
      _fileSize = '';
    });
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newId = 'RES-$timestamp';

    final newRecord = ResearchRecord(
      id: newId,
      organization: _selectedOrganization,
      department: _selectedDepartment,
      facultyName: _selectedFaculty,
      title: _titleController.text.trim(),
      authors: _authorsController.text.trim(),
      type: _selectedType,
      doi: _doiController.text.trim(),
      journalName: _journalController.text.trim(),
      indexing: _selectedIndexing,
      year: _selectedYear,
      description: _descriptionController.text.trim(),
      documentName: _hasUploadedFile ? _fileName : '',
      documentType: _hasUploadedFile ? _fileType : '',
      documentSize: _hasUploadedFile ? _fileSize : '',
      documentStatus: _hasUploadedFile ? 'Uploaded' : 'Not Uploaded',
      metadataMatch: true,
      duplicateFlag: false,
      status: 'Pending Examination',
      verificationChecklist: {
        'Paper Title': 'Pending',
        'Authors': 'Pending',
        'Faculty Affiliation': 'Pending',
        'Department': 'Pending',
        'Publication Details': 'Pending',
        'DOI': 'Pending',
        'Journal / Conference': 'Pending',
        'Indexing Information': 'Pending',
      },
      auditorRemarks: '',
    );

    widget.state.addResearchRecord(newRecord);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 650;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.all(isMobile ? 8 : 24),
      backgroundColor: Colors.white,
      child: Container(
        width: isMobile ? double.infinity : 780,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: EdgeInsets.all(isMobile ? 14 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Title Bar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.note_add_rounded, color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Add Research Paper',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Submit research paper details & supporting manuscript for audit examination.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Form Scrollable Body
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SECTION 1: FACULTY INFORMATION
                      _buildSectionHeader('1. Faculty & Organization Information', Icons.business_rounded),
                      const SizedBox(height: 12),
                      
                      if (isMobile) ...[
                        _buildDropdownField('Research Organization', _organizations, _selectedOrganization, (val) => setState(() => _selectedOrganization = val!)),
                        const SizedBox(height: 12),
                        _buildDropdownField('Department', _departmentFaculty.keys.toList(), _selectedDepartment, (val) {
                          setState(() {
                            _selectedDepartment = val!;
                            _selectedFaculty = _departmentFaculty[_selectedDepartment]!.first;
                            _authorsController.text = _selectedFaculty;
                          });
                        }),
                        const SizedBox(height: 12),
                        _buildDropdownField('Research Faculty / Professor', _departmentFaculty[_selectedDepartment]!, _selectedFaculty, (val) {
                          setState(() {
                            _selectedFaculty = val!;
                            _authorsController.text = _selectedFaculty;
                          });
                        }),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildDropdownField('Research Organization', _organizations, _selectedOrganization, (val) => setState(() => _selectedOrganization = val!))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField('Department', _departmentFaculty.keys.toList(), _selectedDepartment, (val) {
                                setState(() {
                                  _selectedDepartment = val!;
                                  _selectedFaculty = _departmentFaculty[_selectedDepartment]!.first;
                                  _authorsController.text = _selectedFaculty;
                                });
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildDropdownField('Research Faculty / Professor', _departmentFaculty[_selectedDepartment]!, _selectedFaculty, (val) {
                          setState(() {
                            _selectedFaculty = val!;
                            _authorsController.text = _selectedFaculty;
                          });
                        }),
                      ],

                      const SizedBox(height: 20),

                      // SECTION 2: RESEARCH PAPER DETAILS
                      _buildSectionHeader('2. Research Paper Details', Icons.description_rounded),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: _titleController,
                        label: 'Research Paper Title *',
                        hint: 'e.g. Automated ERP Ledger Audit Framework using Immutable Systems',
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter research paper title' : null,
                      ),
                      const SizedBox(height: 12),

                      if (isMobile) ...[
                        _buildTextField(controller: _authorsController, label: 'Authors', hint: 'e.g. Dr. R. Kumar, Prof. P. Anand'),
                        const SizedBox(height: 12),
                        _buildDropdownField('Publication Type', _types, _selectedType, (val) => setState(() => _selectedType = val!)),
                        const SizedBox(height: 12),
                        _buildDropdownField('Publication Year', _years, _selectedYear, (val) => setState(() => _selectedYear = val!)),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _authorsController, label: 'Authors', hint: 'e.g. Dr. R. Kumar, Prof. P. Anand')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildDropdownField('Publication Type', _types, _selectedType, (val) => setState(() => _selectedType = val!))),
                            const SizedBox(width: 12),
                            SizedBox(width: 120, child: _buildDropdownField('Year', _years, _selectedYear, (val) => setState(() => _selectedYear = val!))),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),

                      if (isMobile) ...[
                        _buildTextField(controller: _journalController, label: 'Journal / Conference Name', hint: 'e.g. IEEE Transactions on Learning Technologies'),
                        const SizedBox(height: 12),
                        _buildTextField(controller: _doiController, label: 'DOI Reference', hint: 'e.g. 10.1109/ICERP.2025.998231'),
                        const SizedBox(height: 12),
                        _buildDropdownField('Indexing', _indexings, _selectedIndexing, (val) => setState(() => _selectedIndexing = val!)),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: _buildTextField(controller: _journalController, label: 'Journal / Conference Name', hint: 'e.g. IEEE Transactions on Learning Technologies')),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTextField(controller: _doiController, label: 'DOI Reference', hint: 'e.g. 10.1109/ICERP.2025.998231')),
                            const SizedBox(width: 12),
                            SizedBox(width: 160, child: _buildDropdownField('Indexing', _indexings, _selectedIndexing, (val) => setState(() => _selectedIndexing = val!))),
                          ],
                        ),
                      ],

                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Publication Details / Abstract Description',
                        hint: 'Brief description of research scope and findings...',
                        maxLines: 2,
                      ),

                      const SizedBox(height: 20),

                      // SECTION 3: CORE DOCUMENT UPLOAD COMPONENT
                      _buildSectionHeader('3. Research Paper Document Upload', Icons.cloud_upload_rounded),
                      const SizedBox(height: 10),

                      if (!_hasUploadedFile)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded, size: 32, color: AppColors.accent),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Upload your research paper',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Drag & drop your file here OR click Browse',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: _simulateFileUpload,
                                icon: const Icon(Icons.folder_open_rounded, size: 16),
                                label: const Text('Browse Files'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Supported formats: PDF, DOC, DOCX (Max 15MB)',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.insert_drive_file_rounded, color: Color(0xFF10B981), size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fileName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$_fileType • $_fileSize',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Ready to submit',
                                          style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: _removeUploadedFile,
                                icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textSecondary),
                                label: const Text('Replace', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  side: const BorderSide(color: AppColors.border),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('Submit Research Paper'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> options, String currentValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(currentValue) ? currentValue : options.first,
              isExpanded: true,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              selectedItemBuilder: (BuildContext context) {
                return options.map((opt) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      opt,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList();
              },
              items: options.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      opt,
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      softWrap: false,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            isDense: true,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}
