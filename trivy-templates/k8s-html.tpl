<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <title>Trivy Kubernetes Config Report</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 20px; }
    h2 { border-bottom: 1px solid #ddd; }
    .CRITICAL { color: red; }
    .HIGH { color: orange; }
    .MEDIUM { color: goldenrod; }
    .LOW { color: gray; }
  </style>
</head>
<body>

<h1>Trivy Kubernetes Configuration Report</h1>

{{ range . }}
  {{ $file := .Target }}

  {{ if .Misconfigurations }}
    <h2>{{ $file }}</h2>

    {{ range .Misconfigurations }}
      <p>
        <strong>ID:</strong> {{ .ID }}<br>
        <strong>Title:</strong> {{ .Title }}<br>
        <strong>Severity:</strong>
        <span class="{{ .Severity }}">{{ .Severity }}</span><br>
        <strong>Message:</strong> {{ .Message }}
      </p>
    {{ end }}
  {{ end }}
{{ end }}

</body>
</html>
