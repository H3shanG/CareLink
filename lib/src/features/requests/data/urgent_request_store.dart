
class UrgentRequestStore {
  static final List<Map<String, String>> requests = [];

  static void addRequest(Map<String, String> request) {
    requests.add(request);
  }
}
