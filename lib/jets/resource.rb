class Jets::Resource
  extend Memoist

  attr_reader :definition, :replacements
  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

  def template
    standarize(definition)
  end
  memoize :template

  # CloudFormation Resources reference: https://amzn.to/2NKg6ip
  def standarize(*definition)
    Standardizer.new(definition).template
  end

  def logical_id
    id = template.keys.first
    # replace possible {namespace} in the logical id
    id = replacer.replace_value(id)
    Jets::Camelizer.camelize(id)
  end

  def type
    attributes['Type']
  end

  def properties
    attributes['Properties']
  end

  def attributes
    attributes = template.values.first
    attributes = replacer.replace_placeholders(attributes)
    Jets::Camelizer.transform(attributes)
  end

  def parameters
    {}
  end

  def outputs
    {}
  end

  def replacer
    Replacer.new(replacements)
  end
  memoize :replacer

  def permission
    Permission.new(replacements, self)
  end
  memoize :permission
end
