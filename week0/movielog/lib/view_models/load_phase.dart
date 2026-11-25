enum LoadPhase {
  idle, // 아직 요청하지 않음
  loading, // 첫 로딩 중
  ready, // 표시할 목록이 있음
  empty, // 성공했지만 결과가 없음
  error, // 첫 조회 실패
}
