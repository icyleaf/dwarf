module HTTP
  struct Params
    delegate empty?, to: raw_params
  end
end
