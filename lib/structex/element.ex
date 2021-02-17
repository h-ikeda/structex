defprotocol Structex.Element do
  @spec equivalent_stiffness(t, [...], Structex.Tensor.t()) :: Structex.Tensor.t()
  def equivalent_stiffness(element, keys, distortion)
end
