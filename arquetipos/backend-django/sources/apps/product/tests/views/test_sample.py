from django.urls import reverse


def test_ok(api_client):
    # Arrange // Given
    url = reverse('swagger')

    # Act // When

    # Assert // Then
    assert isinstance(url, str)
