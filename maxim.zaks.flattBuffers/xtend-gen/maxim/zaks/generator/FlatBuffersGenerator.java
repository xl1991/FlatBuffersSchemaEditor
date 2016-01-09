/**
 * generated by Xtext
 */
package maxim.zaks.generator;

import java.util.regex.Pattern;
import maxim.zaks.flatBuffers.Schema;
import maxim.zaks.generator.CSharpGenerator;
import maxim.zaks.generator.EagerSwiftGenerator;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.generator.IFileSystemAccess;
import org.eclipse.xtext.generator.IGenerator;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
@SuppressWarnings("all")
public class FlatBuffersGenerator implements IGenerator {
  private CSharpGenerator csGenerator = new CSharpGenerator();
  
  private EagerSwiftGenerator swiftGenerator = new EagerSwiftGenerator();
  
  @Override
  public void doGenerate(final Resource resource, final IFileSystemAccess fsa) {
    EList<EObject> _contents = resource.getContents();
    EObject _head = IterableExtensions.<EObject>head(_contents);
    final Schema schema = ((Schema) _head);
    URI _uRI = resource.getURI();
    String _lastSegment = _uRI.lastSegment();
    String _quote = Pattern.quote(".");
    String[] _split = _lastSegment.split(_quote);
    String fileName = _split[0];
    CharSequence _generate = this.swiftGenerator.generate(schema);
    fsa.generateFile((fileName + ".swift"), _generate);
    CharSequence _generate_1 = this.csGenerator.generate(schema);
    fsa.generateFile((fileName + ".cs"), _generate_1);
  }
}
