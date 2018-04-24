import QtQuick 2.8
import QtGraphicalEffects.private 1.0

Item {
    id: rootItem

    property variant source
    property variant foregroundSource
    property bool cached: false
    property string mode: "subtract"

    SourceProxy {
        id: backgroundSourceProxy
        input: rootItem.source
    }

    SourceProxy {
        id: foregroundSourceProxy
        input: rootItem.foregroundSource
    }

    ShaderEffectSource {
        id: cacheItem
        anchors.fill: parent
        visible: rootItem.cached
        smooth: true
        sourceItem: shaderItem
        live: true
        hideSource: visible
    }

    ShaderEffect {
        id: shaderItem
        property variant backgroundSource: backgroundSourceProxy.output
        property variant foregroundSource: foregroundSourceProxy.output
        property string mode: rootItem.mode
        anchors.fill: parent

        fragmentShader: fragmentShaderBegin + blendModeSubtract + fragmentShaderEnd

        function buildFragmentShader() {
            var shader = fragmentShaderBegin

            switch (mode.toLowerCase()) {
                case "difference" : shader += blendModeDifference; break;
                case "exclusion" : shader += blendModeExclusion; break;
                case "negation" : shader += blendModeNegation; break;
                case "subtract" : shader += blendModeSubtract; break;
                default: shader += "gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);"; break;
            }

            shader += fragmentShaderEnd
            fragmentShader = shader

            backgroundSourceChanged()
        }

        Component.onCompleted: {
            buildFragmentShader()
        }

        onModeChanged: {
            buildFragmentShader()
        }

        property string blendModeDifference: "result.rgb = abs(rgb1 - rgb2);"
        property string blendModeExclusion: "result.rgb = rgb1 + rgb2 - 2.0 * rgb1 * rgb2;"
        property string blendModeNegation: "result.rgb = 1.0 - abs(1.0 - rgb1 - rgb2);"
        property string blendModeSubtract: "result.rgb = rgb1 * ((1.0 - rgb1) * rgb2 + (1.0 - (1.0 - rgb1) * (1.0 - rgb2)));"

        property string fragmentCoreShaderWorkaround: (GraphicsInfo.profile === GraphicsInfo.OpenGLCoreProfile ? "#version 150 core
            #define varying in
            #define texture2D texture
            out vec4 fragColor;
            #define gl_FragColor fragColor
        " : "")

        property string fragmentShaderBegin: fragmentCoreShaderWorkaround + "
            varying mediump vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D backgroundSource;
            uniform lowp sampler2D foregroundSource;

            void main() {
                lowp vec4 result = vec4(0.0);
                lowp vec4 color1 = texture2D(backgroundSource, qt_TexCoord0);
                lowp vec4 color2 = texture2D(foregroundSource, qt_TexCoord0);
                lowp vec3 rgb1 = color1.rgb / max(1.0/256.0, color1.a);
                lowp vec3 rgb2 = color2.rgb / max(1.0/256.0, color2.a);
                highp float a = max(color1.a, color1.a * color2.a);
        "

        property string fragmentShaderEnd: "
//                gl_FragColor.rgb = mix(rgb1, result.rgb, color2.a);
//                gl_FragColor.rbg *= 0;
//                gl_FragColor.a = a;
//                gl_FragColor *= qt_Opacity;
//gl_FragColor.rgb = vec3(1.0, 1.0, 1.0);
                gl_FragColor.rgb = color1.rgb;
//                gl_FragColor.rgba = color1.rgba * 0.8;

//                gl_FragColor.a = color1.a;
            }
        "
    }
}
