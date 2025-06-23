abstract class ApiResponse {
  void onResponse(String response, int responseCode, Enum requestCode);
  void onError(String errorResponse, int responseCode, Enum requestCode);
}
