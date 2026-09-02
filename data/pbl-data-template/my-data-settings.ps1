# 메모장에서 '=' 오른쪽 값과 field 규칙만 자신의 주제에 맞게 바꿉니다.
# 이 파일은 생성기가 읽는 PowerShell 변수 설정입니다. 제공된 형식을 유지하고 값과 규칙만 수정합니다.

$IndexName = 'shop-logs'
$DocumentCount = 1000
$Seed = 20260901
$IdPrefix = 'LOG'
$IdField = 'log_id'
$SampleCount = 30

# choice와 weighted_choice 규칙이 참조하는 도메인별 후보 목록입니다.
$Vocabularies = [ordered]@{
  services   = @('order-api', 'payment-api', 'catalog-api', 'auth-api')
  exceptions = @('SocketTimeoutException', 'NullPointerException', 'IllegalStateException')
}

# 문서는 위에서 아래 순서로 만들어집니다.
# template는 앞에서 만든 field와 {{sequence}}을 사용할 수 있습니다.
$FieldRules = @(
  @{ Name = 'log_id'; Kind = 'id'; Digits = 6 }
  @{ Name = 'timestamp'; Kind = 'date'; Start = '2026-08-18T00:00:00Z'; End = '2026-09-01T00:00:00Z' }
  @{ Name = 'service_name'; Kind = 'choice'; Source = 'services' }
  @{ Name = 'log_level'; Kind = 'weighted_choice'; Values = @(
      @{ Value = 'INFO'; Weight = 70 },
      @{ Value = 'WARN'; Weight = 20 },
      @{ Value = 'ERROR'; Weight = 10 }
    ) }
  @{ Name = 'logger_name'; Kind = 'template'; Template = 'com.shop.{{service_name}}.RequestHandler' }
  @{ Name = 'message'; Kind = 'weighted_choice'; Values = @(
      @{ Value = '요청 처리가 정상적으로 완료되었습니다.'; Weight = 70 },
      @{ Value = '요청 처리 중 재시도가 발생했습니다.'; Weight = 15 },
      @{ Value = '게이트웨이 응답이 3000ms 후 시간 초과되었습니다.'; Weight = 10 },
      @{ Value = '처리 중 예기치 않은 오류가 발생했습니다.'; Weight = 5 }
    ) }
  @{ Name = 'exception_class'; Kind = 'choice'; Source = 'exceptions'; MissingRatio = 0.90 }
  @{ Name = 'http_status'; Kind = 'weighted_choice'; Values = @(
      @{ Value = 200; Weight = 75 },
      @{ Value = 404; Weight = 5 },
      @{ Value = 500; Weight = 10 },
      @{ Value = 504; Weight = 10 }
    ) }
  @{ Name = 'duration_ms'; Kind = 'integer'; Min = 50; Max = 5000 }
  @{ Name = 'trace_id'; Kind = 'template'; Template = 'TRC-{{sequence}}' }
)
