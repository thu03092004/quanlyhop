// một số tên biến chưa hợp lý, cần sửa lại cho rõ ràng hơn
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quanlyhop/core/theme/app_theme.dart';
import 'package:quanlyhop/data/models/permission_model.dart';

class CreateScheduleScreen extends StatefulWidget {
  final List<PermissionModel> permissions;
  const CreateScheduleScreen({super.key, required this.permissions});

  @override
  State<CreateScheduleScreen> createState() => _CreateScheduleScreenState();
}

class _CreateScheduleScreenState extends State<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _roomNameController = TextEditingController();
  final _placeController = TextEditingController();
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 8));

  String _selectedChairman = '';
  String _selectedSecretary = '';
  String _selectedTechnicalSupport = '';
  String _selectedOrganization = '';

  bool _isOnlineMeeting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _placeController.dispose();
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(bool isStartTime) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartTime ? _startTime : _endTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.teal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStartTime ? _startTime : _endTime,
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.teal,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
            ),
            child: child!,
          );
        },
      );

      if (!mounted) return;

      if (time != null) {
        final newDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );

        if (!mounted) return;
        setState(() {
          if (isStartTime) {
            _startTime = newDateTime;
            if (_startTime.isAfter(_endTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            _endTime = newDateTime;
          }
        });
      }
    }
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      // Xử lý lưu lịch họp
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lưu lịch họp thành công!'),
          backgroundColor: Colors.teal,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tạo lịch họp mới',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tên lịch họp
              _buildSectionTitle('Tên lịch họp', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tiêu đề buổi họp',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên lịch họp';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Thời gian
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Thời gian bắt đầu',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(
                          _startTime,
                          () => _selectDateTime(true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          'Thời gian kết thúc',
                          isRequired: true,
                        ),
                        const SizedBox(height: 8),
                        _buildDateTimeField(
                          _endTime,
                          () => _selectDateTime(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Hình thức họp
              _buildSectionTitle('Hình thức họp'),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Trực tuyến'),
                subtitle: const Text(
                  'Nhấn vào ô chọn nếu họp trực tuyến',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                value: _isOnlineMeeting,
                onChanged: (value) {
                  setState(() {
                    _isOnlineMeeting = value ?? false;
                  });
                },
                contentPadding: EdgeInsets.zero,
                activeColor: Colors.teal,
              ),

              const SizedBox(height: 24),

              // Địa điểm phòng họp
              _buildSectionTitle('Địa điểm phòng họp'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(
                  hintText: 'Nhập địa điểm phòng họp',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Tên phòng họp
              _buildSectionTitle('Tên phòng họp', isRequired: true),

              const SizedBox(height: 8),

              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập tên phòng họp',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên phòng họp';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Nội dung
              _buildSectionTitle('Nội dung', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập nội dung cuộc họp';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Chủ trì điều hành
              _buildDropdownSection(
                'Chủ trì điều hành',
                _selectedChairman,
                (value) => setState(() => _selectedChairman = value),
              ),

              const SizedBox(height: 16),

              // Thư ký cuộc họp
              _buildDropdownSection(
                'Thư ký cuộc họp',
                _selectedSecretary,
                (value) => setState(() => _selectedSecretary = value),
              ),

              const SizedBox(height: 16),

              // Chuyên viên hỗ trợ kỹ thuật
              _buildDropdownSection(
                'Chuyên viên hỗ trợ kỹ thuật',
                _selectedTechnicalSupport,
                (value) => setState(() => _selectedTechnicalSupport = value),
              ),

              const SizedBox(height: 16),

              // Lịch họp cho đơn vị
              _buildDropdownSection(
                'Lịch họp cho đơn vị',
                _selectedOrganization,
                (value) => setState(() => _selectedOrganization = value),
                subtitle:
                    '(Nếu không chọn sẽ mặc định theo đơn vị của người tạo lịch)',
              ),

              const SizedBox(height: 16),

              // Danh sách cán bộ hỗ trợ
              _buildDropdownSection('Danh sách cán bộ hỗ trợ', '', (value) {}),

              const SizedBox(height: 32),

              // Nút Lưu và Tiếp tục
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveSchedule,
                      icon: const Icon(Icons.save),
                      label: const Text('Lưu'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.teal),
                        foregroundColor: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveSchedule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: const Text('Tiếp tục'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField(DateTime dateTime, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${dateTime.day.toString().padLeft(2, '0')}/'
                '${dateTime.month.toString().padLeft(2, '0')}/'
                '${dateTime.year} '
                '${dateTime.hour.toString().padLeft(2, '0')}:'
                '${dateTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    String title,
    String value,
    Function(String) onChanged, {
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value.isEmpty ? null : value,
          decoration: const InputDecoration(
            hintText: '-- Tìm kiếm --',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          items: const [], // Thêm danh sách items tương ứng
          onChanged: (newValue) => onChanged(newValue ?? ''),
        ),
      ],
    );
  }
}
