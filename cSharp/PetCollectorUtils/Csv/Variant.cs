namespace PetCollectorUtils
{
  public class Variant : ISerializable
  {
    public int displayId;
    public double probability;

    public Variant(int displayId, double probability)
    { 
      this.displayId = displayId;
      this.probability = probability;
    }

    public string Serialize()
    {
      return $"{{id={displayId}, chance={probability}}}";
    }

    public override string ToString()
    {
      return Serialize();
    }
  }
}