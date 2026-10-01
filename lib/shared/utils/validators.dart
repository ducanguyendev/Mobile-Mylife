class Validators {
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên.';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2 || trimmed.length > 50) {
      return 'Họ và tên phải từ 2 đến 50 ký tự.';
    }
    // Chỉ chấp nhận chữ cái (kể cả tiếng Việt có dấu) và khoảng trắng
    final regex = RegExp(r'^[\p{L}\s]+$', unicode: true);
    if (!regex.hasMatch(trimmed)) {
      return 'Họ và tên không được chứa số hoặc ký tự đặc biệt.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại.';
    }
    final trimmed = value.trim();
    final regex = RegExp(r'^(0[3|5|7|8|9])[0-9]{8}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Số điện thoại không hợp lệ (10 số, đầu 03/05/07/08/09).';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập địa chỉ email.';
    }
    final trimmed = value.trim();
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Địa chỉ email không đúng định dạng chuẩn.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu.';
    }
    if (value.length < 8 || value.length > 72) {
      return 'Mật khẩu phải có độ dài từ 8 đến 72 ký tự.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu.';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không trùng khớp.';
    }
    return null;
  }
}
